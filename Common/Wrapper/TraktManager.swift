//
//  TraktManager.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/4/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

public extension Notification.Name {
    static let TraktAccountStatusDidChange = Notification.Name(rawValue: "signedInToTrakt")
}

public class TraktManager {
    
    // TODO List:
    // 1. Create a limit object, double check every paginated API call is marked as paginated
    // 2. Call completion with custom error when creating request fails
    
    // MARK: - Properties
    
    private enum Constants {
        static let tokenExpirationDefaultsKey = "accessTokenExpirationDate"
        static let oneMonth: TimeInterval = 2629800
    }
    
    // MARK: Internal
    private var staging: Bool?
    private var clientID: String?
    private var clientSecret: String?
    private var redirectURI: String?
    private var baseURL: String?
    private var APIBaseURL: String?
    private var isWaitingToToken: Bool = false
    let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    // Keys
    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"
    
    let session: URLSessionProtocol

    @available(macOS 12.0, iOS 15.0, *)
    lazy var explore: ExploreResource = ExploreResource(traktManager: self)
    
    // MARK: Public
    public static let sharedManager = TraktManager()
    
    public var isSignedIn: Bool {
        get {
            return accessToken != nil
        }
    }
    public var oauthURL: URL?
    
    private var _accessToken: String?
    public var accessToken: String? {
        get {
            if _accessToken != nil {
                return _accessToken
            }
            if let accessTokenData = MLKeychain.loadData(forKey: accessTokenKey) {
                if let accessTokenString = String(data: accessTokenData, encoding: .utf8) {
                    _accessToken = accessTokenString
                    return accessTokenString
                }
            }
            
            return nil
        }
        set {
            // Save somewhere secure
            _accessToken = newValue
            if newValue == nil {
                // Remove from keychain
                MLKeychain.deleteItem(forKey: accessTokenKey)
            } else {
                // Save to keychain
                let succeeded = MLKeychain.setString(value: newValue!, forKey: accessTokenKey)
                #if DEBUG
                    print("Saved access token: \(succeeded)")
                #endif
            }
        }
    }
    
    private var _refreshToken: String?
    public var refreshToken: String? {
        get {
            if _refreshToken != nil {
                return _refreshToken
            }
            if let refreshTokenData = MLKeychain.loadData(forKey: refreshTokenKey) {
                if let refreshTokenString = String.init(data: refreshTokenData, encoding: .utf8) {
                    _refreshToken = refreshTokenString
                    return refreshTokenString
                }
            }
            
            return nil
        }
        set {
            // Save somewhere secure
            _refreshToken = newValue
            if newValue == nil {
                // Remove from keychain
                MLKeychain.deleteItem(forKey: refreshTokenKey)
            } else {
                // Save to keychain
                let succeeded = MLKeychain.setString(value: newValue!, forKey: refreshTokenKey)
                #if DEBUG
                    print("Saved refresh token: \(succeeded)")
                #endif
            }
        }
    }
    
    // MARK: - Lifecycle
    
    public init(session: URLSessionProtocol = URLSession(configuration: .default)) {
        self.session = session
    }
    
    // MARK: - Setup
    
    public func set(clientID: String, clientSecret secret: String, redirectURI: String, staging: Bool = false) {
        self.clientID = clientID
        self.clientSecret = secret
        self.redirectURI = redirectURI
        self.staging = staging
        
        self.baseURL = !staging ? "trakt.tv" : "staging.trakt.tv"
        self.APIBaseURL = !staging ? "api.trakt.tv" : "api-staging.trakt.tv"
        self.oauthURL = URL(string: "https://\(baseURL!)/oauth/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)")
    }
    
    internal func createErrorWithStatusCode(_ statusCode: Int) -> NSError {
        let message: String
        
        if let traktMessage = StatusCodes.message(for: statusCode) {
            message = traktMessage
        } else {
            message = "Request Failed: Gateway timed out (\(statusCode))"
        }
        
        let userInfo = [
            "title": "Error",
            NSLocalizedDescriptionKey: message,
            NSLocalizedFailureReasonErrorKey: "",
            NSLocalizedRecoverySuggestionErrorKey: ""
        ]
        let TraktKitIncorrectStatusError = NSError(domain: "com.litteral.TraktKit", code: statusCode, userInfo: userInfo)
        
        return TraktKitIncorrectStatusError
    }
    
    // MARK: - Actions
    
    public func signOut() {
        accessToken = nil
        refreshToken = nil
        UserDefaults.standard.removeObject(forKey: Constants.tokenExpirationDefaultsKey)
    }
    
    internal func mutableRequestForURL(_ url: URL?, authorization: Bool, HTTPMethod: Method) -> URLRequest? {
        guard
            let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        if let clientID = clientID {
            request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        }
        
        if authorization {
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            else {
                return nil
            }
        }
        
        return request
    }
    
    internal func mutableRequest(forPath path: String, withQuery query: [String: String], isAuthorized authorized: Bool, withHTTPMethod httpMethod: Method) -> URLRequest? {
        guard let apiBaseURL = APIBaseURL else { preconditionFailure("Call `set(clientID:clientSecret:redirectURI:staging:)` before making any API requests") }
        let urlString = "https://\(apiBaseURL)/" + path
        guard var components = URLComponents(string: urlString) else { return nil }
        
        if query.isEmpty == false {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }
        
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        if let clientID = clientID {
            request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        }

        if authorized {
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    func post<Body: Encodable>(_ path: String, query: [String: String] = [:], body: Body) -> URLRequest? {
        guard let apiBaseURL = APIBaseURL else { preconditionFailure("Call `set(clientID:clientSecret:redirectURI:staging:)` before making any API requests") }
        let urlString = "https://\(apiBaseURL)/" + path
        guard var components = URLComponents(string: urlString) else { return nil }
        if query.isEmpty == false {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }
        
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = Method.POST.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        if let clientID = clientID {
            request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        }
        
        if let accessToken = accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try jsonEncoder.encode(body)
        } catch {
            return nil
        }
        return request
    }

    // MARK: - Authentication
    
    public func getTokenFromAuthorizationCode(code: String, completionHandler: SuccessCompletionHandler?) throws {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret,
            let redirectURI = redirectURI
        else {
            completionHandler?(.fail)
            return
        }
        
        let urlString = "https://\(baseURL!)/oauth/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler?(.fail)
            return
        }
        
        let json = [
            "code": code,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
            ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        
        session._dataTask(with: request) { [weak self] data, response, error in
            guard
                let welf = self else { return }
            guard error == nil else {
                completionHandler?(.fail)
                return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == StatusCodes.Success else {
                completionHandler?(.fail)
                return
            }
            
            // Check data
            guard
                let data = data else {
                completionHandler?(.fail)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let authenticationInfo = try decoder.decode(AuthenticationInfo.self, from: data)
                #if DEBUG
                print(authenticationInfo)
                print("[\(#function)] Access token is \(String(describing: welf.accessToken))")
                print("[\(#function)] Refresh token is \(String(describing: welf.refreshToken))")
                #endif
                
                welf.accessToken = authenticationInfo.accessToken
                welf.refreshToken = authenticationInfo.refreshToken
                // Save expiration date
                let expiresDate = Date(timeIntervalSinceNow: authenticationInfo.expiresIn)
                UserDefaults.standard.set(expiresDate, forKey: Constants.tokenExpirationDefaultsKey)
                
                // Post notification
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .TraktAccountStatusDidChange, object: nil)
                }
                
                completionHandler?(.success)
            } catch {
                completionHandler?(.fail)
            }
        }.resume()
    }
    
    public func getAppCode(completionHandler: @escaping (_ result: DeviceCode?) -> Void) {
        guard let clientID = clientID else {
            completionHandler(nil)
            return
        }
        let urlString = "https://\(APIBaseURL!)/oauth/device/code/"
        
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler(nil)
            return
        }
        
        let json = ["client_id": clientID]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            
            session._dataTask(with: request) { data, response, error in
                guard error == nil else {
                    completionHandler(nil)
                    return
                }
                
                // Check response
                guard
                    let HTTPResponse = response as? HTTPURLResponse,
                    HTTPResponse.statusCode == StatusCodes.Success
                else {
                    completionHandler(nil)
                    return
                }
                
                // Check data
                guard let data = data else {
                    completionHandler(nil)
                    return
                }
                do {
                    let deviceCode = try JSONDecoder().decode(DeviceCode.self, from: data)
                    completionHandler(deviceCode)
                } catch {
                    completionHandler(nil)
                }
            }.resume()
        } catch {
            completionHandler(nil)
        }
    }
    
    public func getTokenFromDevice(code: DeviceCode?, completionHandler: ProgressCompletionHandler?) {
        guard
            let clientID = self.clientID,
            let clientSecret = self.clientSecret,
            let deviceCode = code
        else {
            completionHandler?(.fail(0))
            return
        }
        
        let urlString = "https://\(APIBaseURL!)/oauth/device/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler?(.fail(0))
            return
        }
        
        let json = [
            "code": deviceCode.deviceCode,
            "client_id": clientID,
            "client_secret": clientSecret,
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            completionHandler?(.fail(0))
            return
        }
        request.httpBody = body
        self.isWaitingToToken = true
        
        DispatchQueue.global().async {
            var i = 1
            while self.isWaitingToToken {
                if i >= deviceCode.expiresIn {
                    self.isWaitingToToken = false
                    continue
                }
                self.send(request: request, count: i) { result in
                    completionHandler?(result)
                    switch result {
                    case .success:
                        self.isWaitingToToken = false
                    case .fail(let progress):
                        if progress == 0 {
                            self.isWaitingToToken = false
                        }
                    }
                }
                i += 1
                sleep(1)
            }
        }
    }
    
    private func send(request: URLRequest, count: Int, completionHandler: ProgressCompletionHandler?) {
        session._dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                completionHandler?(.fail(0))
                return
            }
            
            // Check response
            if let HTTPResponse = response as? HTTPURLResponse,
               HTTPResponse.statusCode == StatusCodes.BadRequest {
                completionHandler?(.fail(count))
                return
            }
            
            guard let HTTPResponse = response as? HTTPURLResponse,
                  HTTPResponse.statusCode == StatusCodes.Success else {
                completionHandler?(.fail(0))
                return
            }
            
            // Check data
            guard let data = data else {
                completionHandler?(.fail(0))
                return
            }
            
            do {
                if let accessTokenDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    self.saveCredentials(accessTokenDict)
                    completionHandler?(.success)
                }
            } catch {
                completionHandler?(.fail(0))
            }
        }.resume()
    }
    
    private func saveCredentials(_ credentials: [String: AnyObject]) {
        self.accessToken = credentials["access_token"] as? String
        self.refreshToken = credentials["refresh_token"] as? String
        
        #if DEBUG
        print("[\(#function)] Access token is \(String(describing: self.accessToken))")
        print("[\(#function)] Refresh token is \(String(describing: self.refreshToken))")
        #endif
        
        // Save expiration date
        let timeInterval = credentials["expires_in"] as! NSNumber
        let expiresDate = Date(timeIntervalSinceNow: timeInterval.doubleValue)
        
        UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
        UserDefaults.standard.synchronize()
        
        // Post notification
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .TraktAccountStatusDidChange, object: nil)
        }
    }
    
    // MARK: Refresh access token
    
    public enum RefreshState {
        case noTokens, validTokens, refreshTokens, expiredTokens
    }
    
    public enum RefreshTokenError: Error {
        case missingRefreshToken, invalidRequest, invalidRefreshToken, unsuccessfulNetworkResponse(Int), missingData, expiredTokens
    }
    
    /// Returns the local token state. This could be wrong if a user revokes application access from Trakt.tv
    public var refreshState: RefreshState {
        guard let expiredDate = UserDefaults.standard.object(forKey: Constants.tokenExpirationDefaultsKey) as? Date else {
            return .noTokens
        }
        let refreshDate = expiredDate.addingTimeInterval(-Constants.oneMonth)
        let now = Date()
        
        if now >= expiredDate {
            return .expiredTokens
        }
        
        if now >= refreshDate {
            return .refreshTokens
        }
        
        return .validTokens
    }
    
    public func checkToRefresh(completion: @escaping (_ result: Swift.Result<Void, Error>) -> Void) {
        switch refreshState {
        case .refreshTokens:
            do {
                try getAccessTokenFromRefreshToken(completionHandler: completion)
            } catch {
                completion(.failure(error))
            }
        case .expiredTokens:
            completion(.failure(RefreshTokenError.expiredTokens))
        default:
            completion(.success(()))
        }
    }
    
    public func getAccessTokenFromRefreshToken(completionHandler: @escaping (_ result: Swift.Result<Void, Error>) -> Void) throws {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret,
            let redirectURI = redirectURI,
            let rToken = refreshToken
            else {
                completionHandler(.failure(RefreshTokenError.missingRefreshToken))
                return
        }
        
        let urlString = "https://\(baseURL!)/oauth/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler(.failure(RefreshTokenError.invalidRequest))
            return
        }
        
        let json = [
            "refresh_token": rToken,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "refresh_token",
            ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        
        session._dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse else { return }
            
            switch HTTPResponse.statusCode {
            case 401:
                completionHandler(.failure(RefreshTokenError.invalidRefreshToken))
            case 200...299: // Success
                break
            default:
                completionHandler(.failure(RefreshTokenError.unsuccessfulNetworkResponse(HTTPResponse.statusCode)))
            }
            
            // Check data
            guard let data = data else {
                completionHandler(.failure(RefreshTokenError.missingData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let authenticationInfo = try decoder.decode(AuthenticationInfo.self, from: data)
                #if DEBUG
                print(authenticationInfo)
                print("[\(#function)] Access token is \(String(describing: welf.accessToken))")
                print("[\(#function)] Refresh token is \(String(describing: welf.refreshToken))")
                #endif
                
                welf.accessToken = authenticationInfo.accessToken
                welf.refreshToken = authenticationInfo.refreshToken
                // Save expiration date
                let expiresDate = Date(timeIntervalSinceNow: authenticationInfo.expiresIn)
                UserDefaults.standard.set(expiresDate, forKey: Constants.tokenExpirationDefaultsKey)
                UserDefaults.standard.synchronize()
                
                completionHandler(.success(()))
            } catch {
                completionHandler(.failure(error))
            }
        }.resume()
    }
}
