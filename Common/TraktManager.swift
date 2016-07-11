//
//  TraktManager.swift
//  TVShows
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

/// Generic result type
public enum ObjectResultType<T: TraktProtocol> {
    case success(object: T)
    case error(error: NSError?)
}

/// Generic result type
public enum ObjectsResultType<T: TraktProtocol> {
    case success(objects: [T])
    case error(error: NSError?)
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
    
    // MARK: Result Types
    public enum DictionaryResultType {
        case success(dict: RawJSON)
        case error(error: NSError?)
    }
    
    public enum SuccessResultType {
        case success
        case fail
    }
    
    public enum ArrayResultType {
        case success(array: [RawJSON])
        case error(error: NSError?)
    }
    
    public enum CommentsResultType {
        case success(comments: [Comment])
        case error(error: NSError?)
    }
    
    public enum CastCrewResultType {
        case success(cast: [CastMember], crew: [CrewMember])
        case error(error: NSError?)
    }
    
    // MARK: Completion handlers
    public typealias ResultCompletionHandler        = (result: DictionaryResultType) -> Void
    public typealias SuccessCompletionHandler       = (result: SuccessResultType) -> Void
    public typealias ArrayCompletionHandler         = (result: ArrayResultType) -> Void
    public typealias CommentsCompletionHandler      = (result: CommentsResultType) -> Void
    public typealias CastCrewCompletionHandler      = (result: CastCrewResultType) -> Void
    
    // MARK: - Completion handlers
    public typealias SearchCompletionHandler        = ((result: ObjectsResultType<TraktSearchResult>) -> Void)
    public typealias statsCompletionHandler         = ((result: ObjectResultType<TraktStats>) -> Void)
    
    // TV
    public typealias ShowCompletionHandler          = ((result: ObjectResultType<TraktShow>) -> Void)
    public typealias ShowsCompletionHandler         = ((result: ObjectsResultType<TraktShow>) -> Void)
    public typealias TrendingShowsCompletionHandler = ((result: ObjectsResultType<TraktTrendingShow>) -> Void)
    public typealias MostShowsCompletionHandler     = ((result: ObjectsResultType<TraktMostShow>) -> Void)
    public typealias ShowTranslationsCompletionHandler = ((result: ObjectsResultType<TraktShowTranslation>) -> Void)
    public typealias SeasonsCompletionHandler       = ((result: ObjectsResultType<TraktSeason>) -> Void)
    public typealias WatchedShowsCompletionHandler  = ((result: ObjectsResultType<TraktWatchedShow>) -> Void)
    
    // Movies
    public typealias MovieCompletionHandler          = ((result: ObjectResultType<TraktMovie>) -> Void)
    public typealias MoviesCompletionHandler         = ((result: ObjectsResultType<TraktMovie>) -> Void)
    public typealias TrendingMoviesCompletionHandler = ((result: ObjectsResultType<TraktTrendingMovie>) -> Void)
    public typealias MostMoviesCompletionHandler     = ((result: ObjectsResultType<TraktMostShow>) -> Void)
    public typealias MovieTranslationsCompletionHandler = ((result: ObjectsResultType<TraktMovieTranslation>) -> Void)
    public typealias WatchedMoviesCompletionHandler  = ((result: ObjectsResultType<TraktWatchedMovie>) -> Void)
    public typealias BoxOfficeMoviesCompletionHandler  = ((result: ObjectsResultType<TraktBoxOfficeMovie>) -> Void)
    
    // Sync
    public typealias LastActivitiesCompletionHandler = ((result: ObjectResultType<TraktLastActivities>) -> Void)
    
    // Users
    public typealias ListCompletionHandler          = ((result: ObjectResultType<TraktList>) -> Void)
    public typealias ListsCompletionHandler         = ((result: ObjectsResultType<TraktList>) -> Void)
    public typealias ListItemCompletionHandler      = ((result: ObjectsResultType<TraktListItem>) -> Void)
    
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
        let userInfo = [
            "title": "Trakt",
            NSLocalizedDescriptionKey: "Request Failed: Gateway timed out (\(statusCode))",
            NSLocalizedFailureReasonErrorKey: "",
            NSLocalizedRecoverySuggestionErrorKey: ""
        ]
        let TraktKitIncorrectStatusError = NSError(domain: "com.litteral.TraktKit", code: statusCode, userInfo: userInfo)
        
        return TraktKitIncorrectStatusError
    }
    
    // MARK: - Actions
    
    public func mutableRequestForURL(_ url: URL?, authorization: Bool, HTTPMethod: Method) -> URLRequest? {
        guard let url = url else { return nil }
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
        let urlString = "https://api-v2launch.trakt.tv/" + path
        guard var components = URLComponents(string: urlString) else { return nil }
        var queryItems: [URLQueryItem] = []
        for (key, value) in query {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems
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
            else {
                return nil
            }
        }
        
        return request
    }
    
    func createJsonData(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON]) throws -> Data? {
        let json = [
            "movies": movies,
            "shows": shows,
            "episodes": episodes,
            ]
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    // MARK: Perform Requests
    
    /// Dictionary
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: ResultCompletionHandler) -> URLSessionDataTask? {
        
        let datatask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let wSelf = self else { return }
            guard error == nil else { return completion(result: .error(error: error)) }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(result: .error(error: wSelf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(result: .error(error: nil))
                    }
                    return
            }
            
            // Check data
            guard let data = data else { return completion(result: .error(error: TraktKitNoDataError)) }
            
            do {
                
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    completion(result: .success(dict: dict))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(result: .error(error: jsonSerializationError))
            }
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Array
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let wSelf = self else { return }
            guard error == nil else { return completion(result: .error(error: error)) }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(result: .error(error: wSelf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(result: .error(error: nil))
                    }
                    
                    return
            }
            
            // Check data
            guard let data = data else { return completion(result: .error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [RawJSON] {
                    completion(result: .success(array: array))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(result: .error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Success / Failure
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: SuccessCompletionHandler) -> URLSessionDataTask? {
        let datatask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { return completion(result: .fail) }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse
                where HTTPResponse.statusCode == code else { return completion(result: .fail) }
            
            // Check data
            guard data != nil else { return completion(result: .fail) }
            
            completion(result: .success)
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Comments
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: CommentsCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ArrayCompletionHandler = { (result: ArrayResultType) -> Void in
            
            switch result {
            case .success(let array):
                let comments: [Comment] = initEach(array)
                completion(result: .success(comments: comments))
            case .error(let error):
                completion(result: .error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Cast and crew
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: CastCrewCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ResultCompletionHandler = { (result: DictionaryResultType) -> Void in
            switch result {
            case .success(let dict):
                var crew: [CrewMember] = []
                var cast: [CastMember] = []
                
                // Crew
                if let jsonCrew = dict["crew"] as? RawJSON {
                    func addMembers(_ members: [RawJSON]) {
                        crew += initEach(members)
                    }
                    
                    if let members = jsonCrew["production"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["writing"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["crew"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["camera"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["sound"] as? [RawJSON] { addMembers(members) }
                }
                
                // Cast
                if let members = dict["cast"] as? [[String: AnyObject]] {
                    cast += initEach(members)
                }
                
                completion(result: .success(cast: cast, crew: crew))
            case .error(let error):
                completion(result: .error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    // Generic array of Trakt objects
    func performRequest<T: TraktProtocol>(request: URLRequest, expectingStatusCode code: Int, completion: ((result: ObjectResultType<T>) -> Void)) -> URLSessionDataTask? {
        
        let aCompletion: ResultCompletionHandler = { (result) -> Void in
            switch result {
            case .success(let dict):
                guard let traktObject = T(json: dict) else { return completion(result: .error(error: nil)) }
                completion(result: .success(object: traktObject))
            case .error(let error):
                completion(result: .error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Array of TraktProtocol objects
    func performRequest<T: TraktProtocol>(request: URLRequest, expectingStatusCode code: Int, completion: ((result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let wSelf = self else { return }
            guard error == nil else { return completion(result: .error(error: error)) }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(result: .error(error: wSelf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(result: .error(error: nil))
                    }
                    
                    return
            }
            
            // Check data
            guard let data = data else { return completion(result: .error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [RawJSON] {
                    let objects: [T] = initEach(array)
                    completion(result: .success(objects: objects))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(result: .error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    // MARK: - Authentication
    
    public func getTokenFromAuthorizationCode(code: String, completionHandler: SuccessCompletionHandler?) throws {
        guard let clientID = clientID,
            clientSecret = clientSecret,
            redirectURI = redirectURI else {
                completionHandler?(result: .fail)
                return
        }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler?(result: .fail)
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
            guard let wSelf = self else { return }
            guard error == nil else {
                completionHandler?(result: .fail)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse
                where HTTPResponse.statusCode == StatusCodes.Success else {
                    completionHandler?(result: .fail)
                    return
            }
            
            // Check data
            guard let data = data else {
                completionHandler?(result: .fail)
                return
            }
            
            do {
                if let accessTokenDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    
                    wSelf.accessToken = accessTokenDict["access_token"] as? String
                    wSelf.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print("[\(#function)] Access token is \(wSelf.accessToken)")
                        print("[\(#function)] Refresh token is \(wSelf.refreshToken)")
                    #endif
                    
                    // Save expiration date
                    let timeInterval = accessTokenDict["expires_in"] as! NSNumber
                    let expiresDate = Date(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
                    UserDefaults.standard.synchronize()
                    
                    // Post notification
                    OperationQueue.main.addOperation({ 
                        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "signedInToTrakt"), object: nil)
                    })
                    
                    completionHandler?(result: .success)
                }
            }
            catch {
                completionHandler?(result: .fail)
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
    
    public func getAccessTokenFromRefreshToken(completionHandler: SuccessCompletionHandler) throws {
        guard let clientID = clientID,
            clientSecret = clientSecret,
            redirectURI = redirectURI else { return completionHandler(result: .fail) }
        
        guard let rToken = refreshToken else { return completionHandler(result: .fail) }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = URL(string: urlString)
        guard var request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else { return completionHandler(result: .fail) }
        
        let json = [
            "refresh_token": rToken,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "refresh_token",
            ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        
        session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let wSelf = self else { return }
            guard error == nil else { return completionHandler(result: .fail) }
            
            // Check response
            guard let HTTPResponse = response as? HTTPURLResponse
                where HTTPResponse.statusCode == StatusCodes.Success else { return completionHandler(result: .fail) }
            
            // Check data
            guard let data = data else { return completionHandler(result: .fail) }
            
            do {
                if let accessTokenDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    
                    wSelf.accessToken = accessTokenDict["access_token"] as? String
                    wSelf.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print(accessTokenDict)
                        print("[\(#function)] Access token is \(wSelf.accessToken)")
                        print("[\(#function)] Refresh token is \(wSelf.refreshToken)")
                    #endif
                    
                    // Save expiration date
                    guard let timeInterval = accessTokenDict["expires_in"] as? NSNumber else { return completionHandler(result: .fail) }
                    let expiresDate = Date(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
                    UserDefaults.standard.synchronize()
                    
                    completionHandler(result: .success)
                }
            }
            catch {
                completionHandler(result: .fail)
            }
        }.resume()
    }
}
