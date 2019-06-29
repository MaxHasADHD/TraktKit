//
//  TraktManager.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/4/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

// Errors
let TraktKitNoDataError = NSError(domain: "com.litteral.TraktKit",
                                  code: -10,
                                  userInfo: ["title": "Trakt",
                                             NSLocalizedDescriptionKey: "No data returned",
                                             NSLocalizedFailureReasonErrorKey: "",
                                             NSLocalizedRecoverySuggestionErrorKey: ""])

public extension Notification.Name {
    static let TraktAccountStatusDidChange = Notification.Name(rawValue: "signedInToTrakt")
}

public class TraktManager {
    
    // TODO List:
    // 1. Create a limit object, double check every paginated API call is marked as paginated
    // 2. Call completion with custom error when creating request fails
    
    // MARK: Internal
    private var staging: Bool?
    private var clientID: String?
    private var clientSecret: String?
    private var redirectURI: String?
    private var baseURL: String?
    private var APIBaseURL: String?
    
    // Keys
    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"
    
    let session: URLSessionProtocol
    
    // MARK: - MDA device codes
    
    public var deviceCode: String?
    public var userCode: String?
    public var verificationURL: String?
    public var timeInterval: TimeInterval?
    public var expiresIn: TimeInterval?
    // END - MDA
    
    // MARK: Public
    public static let sharedManager = TraktManager()
    
    public var isSignedIn: Bool {
        get {
            return accessToken != nil
        }
    }
    public var oauthURL: URL?
    
    public var accessToken: String? {
        get {
            if let accessTokenData = MLKeychain.loadData(forKey: accessTokenKey) {
                if let accessTokenString = String.init(data: accessTokenData, encoding: .utf8) {
                    return accessTokenString
                }
            }
            
            return nil
        }
        set {
            // Save somewhere secure
            
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
    
    public var refreshToken: String? {
        get {
            if let refreshTokenData = MLKeychain.loadData(forKey: refreshTokenKey) {
                if let accessTokenString = String.init(data: refreshTokenData, encoding: .utf8) {
                    return accessTokenString
                }
            }
            
            return nil
        }
        set {
            // Save somewhere secure
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
    
    // MARK: - Setup Clients
    public func setOauth2RedirectURL(withClientID: String, clientSecret secret: String, redirectURI: String, staging: Bool = false) {
        self.clientID = withClientID
        self.clientSecret = secret
        self.redirectURI = redirectURI
        
        self.staging = staging
        
        self.baseURL = !staging ? "trakt.tv" : "staging.trakt.tv"
        self.APIBaseURL = !staging ? "api.trakt.tv" : "api-staging.trakt.tv"
        self.oauthURL = URL(string: "https://\(baseURL!)/oauth/authorize?response_type=code&client_id=\(String(describing: clientID))&redirect_uri=\(redirectURI)")

//        self.oauthURL = URL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(withClientID)&redirect_uri=\(redirectURI)")
    }
    
    // MARK: Renamed
    @available(*, deprecated, renamed: "setOauth2RedirectURL(withClientID:clientSecret:redirectURI:)")
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
    
    internal func createJsonData(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], ids: [NSNumber]? = nil) throws -> Data? {
        var json: [String: Any] = [
            "movies": movies,
            "shows": shows,
            "episodes": episodes,
            ]
        
        if let ids = ids {
            json["ids"] = ids
        }
        
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    // MARK: - MDA Authenticate Devices
    
    public func getDeviceCode(completionHandler: @escaping DataResultCompletionHandler) throws {
        guard let clientID = clientID
            else {
                completionHandler(.error(error: nil))
                return
        }
        
        
        let urlString = "https://trakt.tv/oauth/device/code"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler(.error(error: nil))
            return
        }
        
        let json = [
            "client_id": clientID,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        session._dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else {
                completionHandler(.error(error: error))
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == StatusCodes.Success
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completionHandler(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completionHandler(.error(error: nil))
                    }
                    return
            }
            // Check data
            guard
                let data = data else {
                    completionHandler(.error(error: nil))
                    return
            }
            
            do {
                if let deviceCodeDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    
                    welf.deviceCode = deviceCodeDict["device_code"] as? String
                    welf.userCode = deviceCodeDict["user_code"] as? String
                    welf.verificationURL = deviceCodeDict["verification_url"] as? String
                    welf.timeInterval = deviceCodeDict["interval"] as? TimeInterval
                    welf.expiresIn = deviceCodeDict["expires_in"] as? TimeInterval
                    
                    
                    #if DEBUG
                    print("[\(#function)] Device Code is \(String(describing: welf.deviceCode))")
                    print("[\(#function)] User Code is \(String(describing: welf.userCode))")
                    print("[\(#function)] Verification URL is \(String(describing: welf.verificationURL))")
                    print("[\(#function)] Time Interval is \(String(describing: welf.timeInterval)) sec.")
                    print("[\(#function)] Expires in \(String(describing: welf.expiresIn)) sec.")
                    #endif
                    
                    completionHandler(.success(data: data))
                }
            }
            catch {
                welf.deviceCode = nil
                welf.userCode = nil
                welf.verificationURL = nil
                completionHandler(.error(error: nil))
            }
            }.resume()
    }
    
    public func getTokenFromDeviceCode(completionHandler: SuccessCompletionHandler?) throws {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret,
            let deviceCode = deviceCode else {
                completionHandler?(.fail)
                return
        }
        
        let urlString = "https://trakt.tv/oauth/device/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler?(.fail)
            return
        }
        
        let json = [
            "code": deviceCode,
            "client_id": clientID,
            "client_secret": clientSecret,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        
        session._dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else {
                completionHandler?(.fail)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == StatusCodes.Success else {
                    completionHandler?(.fail)
                    return
            }
            
            // Check data
            guard let data = data else {
                completionHandler?(.fail)
                return
            }
            
            do {
                if let accessTokenDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    
                    welf.accessToken = accessTokenDict["access_token"] as? String
                    welf.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                    print("[\(#function)] Access token is \(String(describing: welf.accessToken))")
                    print("[\(#function)] Refresh token is \(String(describing: welf.refreshToken))")
                    #endif
                    
                    // Save expiration date
                    let timeInterval = accessTokenDict["expires_in"] as! NSNumber
                    let expiresDate = Date(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
                    UserDefaults.standard.synchronize()
                    
                    // Post notification
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .TraktAccountStatusDidChange, object: nil)
                    }
                    
                    completionHandler?(.success)
                }
            }
            catch {
                completionHandler?(.fail)
            }
            }.resume()
    }
    // MARK: - Authentication
    
    public func getTokenFromAuthorizationCode(code: String, completionHandler: SuccessCompletionHandler?) throws {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret,
            let redirectURI = redirectURI else {
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
        
        session._dataTask(with: request) { [weak self] (data, response, error) -> Void in
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
                if let accessTokenDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    
                    welf.accessToken = accessTokenDict["access_token"] as? String
                    welf.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print("[\(#function)] Access token is \(String(describing: welf.accessToken))")
                        print("[\(#function)] Refresh token is \(String(describing: welf.refreshToken))")
                    #endif
                    
                    // Save expiration date
                    let timeInterval = accessTokenDict["expires_in"] as! NSNumber
                    let expiresDate = Date(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
                    UserDefaults.standard.synchronize()
                    
                    // Post notification
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .TraktAccountStatusDidChange, object: nil)
                    }
                    
                    completionHandler?(.success)
                }
            }
            catch {
                completionHandler?(.fail)
            }
            }.resume()
    }
    
    // MARK: Refresh access token
    
    public func needToRefresh() -> Bool {
        if let expirationDate = UserDefaults.standard.object(forKey: "accessTokenExpirationDate") as? Date {
            let today = Date()
            
            if today.compare(expirationDate) == .orderedDescending ||
                today.compare(expirationDate) == .orderedSame {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    public func checkToRefresh(completion: @escaping (_ success: Bool) -> Void) {
        if let expirationDate = UserDefaults.standard.object(forKey: "accessTokenExpirationDate") as? Date {
            let today = Date()
            
            if today.compare(expirationDate) == .orderedDescending ||
                today.compare(expirationDate) == .orderedSame {
                do {
                    try getAccessTokenFromRefreshToken { result in
                        switch result {
                        case .success:
                            completion(true)
                        case .fail:
                            completion(false)
                        }
                    }
                } catch {
                    completion(false)
                }
            } else {
                completion(true)
            }
        } else {
            completion(true)
        }
    }
    
    public func getAccessTokenFromRefreshToken(completionHandler: @escaping SuccessCompletionHandler) throws {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret,
            let redirectURI = redirectURI else {
                completionHandler(.fail)
                return
        }
        
        guard let rToken = refreshToken else {
            completionHandler(.fail)
            return
        }
        
        let urlString = "https://\(baseURL!)/oauth/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler(.fail)
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
            guard error == nil else {
                completionHandler(.fail)
                return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                200...299 ~= HTTPResponse.statusCode else {
                    completionHandler(.fail)
                    return
            }
            
            // Check data
            guard let data = data else {
                completionHandler(.fail)
                return
            }
            
            do {
                if let accessTokenDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    
                    welf.accessToken = accessTokenDict["access_token"] as? String
                    welf.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print(accessTokenDict)
                        print("[\(#function)] Access token is \(String(describing: welf.accessToken))")
                        print("[\(#function)] Refresh token is \(String(describing: welf.refreshToken))")
                    #endif
                    
                    // Save expiration date
                    guard let timeInterval = accessTokenDict["expires_in"] as? NSNumber else {
                        completionHandler(.fail)
                        return
                    }
                    let expiresDate = Date(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
                    UserDefaults.standard.synchronize()
                    
                    completionHandler(.success)
                }
            } catch {
                completionHandler(.fail)
            }
        }.resume()
    }
}
