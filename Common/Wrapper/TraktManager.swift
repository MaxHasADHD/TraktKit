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
    private var clientID: String?
    private var clientSecret: String?
    private var redirectURI: String?
    
    // Keys
    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"
    
    // Lazy
    lazy var session = URLSession(configuration: .default)
    
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
    
    private init() {
        #if DEBUG
            assert(clientID == nil, "Client ID needs to be set")
            assert(clientSecret == nil, "Client secret needs to be set")
            assert(redirectURI == nil, "Redirect URI needs to be set")
        #endif
        
    }
    
    // MARK: - Setup
    
    public func setClientID(clientID: String, clientSecret secret: String, redirectURI: String) {
        self.clientID = clientID
        self.clientSecret = secret
        self.redirectURI = redirectURI
        
        self.oauthURL = URL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)")
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
    
    public func mutableRequestForURL(_ url: URL?, authorization: Bool, HTTPMethod: Method) -> URLRequest? {
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
    
    public func mutableRequest(forPath path: String, withQuery query: [String: String], isAuthorized authorized: Bool, withHTTPMethod httpMethod: Method) -> URLRequest? {
        let urlString = "https://api.trakt.tv/" + path
        guard
            var components = URLComponents(string: urlString) else { return nil }
        
        if query.isEmpty == false {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }
        
        guard
            let url = components.url else { return nil }
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
            else {
                return nil
            }
        }
        
        return request
    }
    
    func createJsonData(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], ids: [NSNumber]? = nil) throws -> Data? {
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
    
    // MARK: - Authentication
    
    public func getTokenFromAuthorizationCode(code: String, completionHandler: SuccessCompletionHandler?) throws {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret,
            let redirectURI = redirectURI else {
                completionHandler?(.fail)
                return
        }
        
        let urlString = "https://trakt.tv/oauth/token"
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
        
        session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
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
    
    public func checkToRefresh() throws {
        if let expirationDate = UserDefaults.standard.object(forKey: "accessTokenExpirationDate") as? Date {
            let today = Date()
            
            if today.compare(expirationDate) == .orderedDescending ||
                today.compare(expirationDate) == .orderedSame {
                #if DEBUG
                    print("[\(#function)] Refreshing token!")
                #endif
                try self.getAccessTokenFromRefreshToken(completionHandler: { (success) -> Void in
                    
                })
            }
            else {
                #if DEBUG
                    print("[\(#function)] No need to refresh token!")
                #endif
            }
        }
    }
    
    public func getAccessTokenFromRefreshToken(completionHandler: @escaping SuccessCompletionHandler) throws {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret,
            let redirectURI = redirectURI else { return completionHandler(.fail) }
        
        guard
            let rToken = refreshToken else { return completionHandler(.fail) }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else { return completionHandler(.fail) }
        
        let json = [
            "refresh_token": rToken,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "refresh_token",
            ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        
        session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard
                let welf = self else { return }
            guard error == nil else { return completionHandler(.fail) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == StatusCodes.Success else {
                    return completionHandler(.fail)
            }
            
            // Check data
            guard
                let data = data else { return completionHandler(.fail) }
            
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
                    guard
                        let timeInterval = accessTokenDict["expires_in"] as? NSNumber else {
                            return completionHandler(.fail)
                    }
                    let expiresDate = Date(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
                    UserDefaults.standard.synchronize()
                    
                    completionHandler(.success)
                }
            }
            catch {
                completionHandler(.fail)
            }
        }.resume()
    }
}
