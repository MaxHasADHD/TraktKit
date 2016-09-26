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
    
    public enum WatchingResultType {
        case checkedIn(watching: TraktWatching)
        case notCheckedIn
        case error(error: NSError?)
    }
    
    public enum HiddenItemsResultType {
        case success(items: [HiddenItem])
        case error(error: Error?)
    }
    
    // MARK: Completion handlers
    public typealias ResultCompletionHandler = (_ result: DictionaryResultType) -> Void
    public typealias SuccessCompletionHandler = (_ result: SuccessResultType) -> Void
    public typealias ArrayCompletionHandler = (_ result: ArrayResultType) -> Void
    public typealias CommentsCompletionHandler = (_ result: CommentsResultType) -> Void
    public typealias CastCrewCompletionHandler = (_ result: CastCrewResultType) -> Void
    
    public typealias watchingCompletionHandler = (_ result: WatchingResultType) -> Void
    
    // MARK: - Completion handlers
    public typealias SearchCompletionHandler = (_ result: ObjectsResultType<TraktSearchResult>) -> Void
    public typealias statsCompletionHandler = (_ result: ObjectResultType<TraktStats>) -> Void
    
    // TV
    public typealias ShowCompletionHandler = (_ result: ObjectResultType<TraktShow>) -> Void
    public typealias ShowsCompletionHandler = (_ result: ObjectsResultType<TraktShow>) -> Void
    public typealias TrendingShowsCompletionHandler = (_ result: ObjectsResultType<TraktTrendingShow>) -> Void
    public typealias MostShowsCompletionHandler = (_ result: ObjectsResultType<TraktMostShow>) -> Void
    public typealias AnticipatedShowCompletionHandler = (_ result: ObjectsResultType<TraktAnticipatedShow>) -> Void
    public typealias ShowTranslationsCompletionHandler = (_ result: ObjectsResultType<TraktShowTranslation>) -> Void
    public typealias SeasonsCompletionHandler = (_ result: ObjectsResultType<TraktSeason>) -> Void
    
    public typealias WatchedShowsCompletionHandler = (_ result: ObjectsResultType<TraktWatchedShow>) -> Void
    public typealias ShowWatchedProgressCompletionHandler = (_ result: ObjectResultType<TraktShowWatchedProgress>) -> Void
    
    // Episodes
    public typealias EpisodeCompletionHandler = (_ result: ObjectsResultType<TraktEpisode>) -> Void
    public typealias EpisodesCompletionHandler = (_ result: ObjectsResultType<TraktEpisode>) -> Void
    
    // Movies
    public typealias MovieCompletionHandler = (_ result: ObjectResultType<TraktMovie>) -> Void
    public typealias MoviesCompletionHandler = (_ result: ObjectsResultType<TraktMovie>) -> Void
    public typealias TrendingMoviesCompletionHandler = (_ result: ObjectsResultType<TraktTrendingMovie>) -> Void
    public typealias MostMoviesCompletionHandler = (_ result: ObjectsResultType<TraktMostShow>) -> Void
    public typealias AnticipatedMovieCompletionHandler = (_ result: ObjectsResultType<TraktAnticipatedMovie>) -> Void
    public typealias MovieTranslationsCompletionHandler = (_ result: ObjectsResultType<TraktMovieTranslation>) -> Void
    public typealias WatchedMoviesCompletionHandler = (_ result: ObjectsResultType<TraktWatchedMovie>) -> Void
    public typealias BoxOfficeMoviesCompletionHandler = (_ result: ObjectsResultType<TraktBoxOfficeMovie>) -> Void
    
    // Sync
    public typealias LastActivitiesCompletionHandler = (_ result: ObjectResultType<TraktLastActivities>) -> Void
    public typealias RatingsCompletionHandler = (_ result: ObjectsResultType<TraktRating>) -> Void
    
    // Users
    public typealias ListCompletionHandler = (_ result: ObjectResultType<TraktList>) -> Void
    public typealias ListsCompletionHandler = (_ result: ObjectsResultType<TraktList>) -> Void
    public typealias ListItemCompletionHandler = (_ result: ObjectsResultType<TraktListItem>) -> Void
    public typealias HiddenItemsCompletionHandler = (_ result: HiddenItemsResultType) -> Void
    
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
        let urlString = "https://api-v2launch.trakt.tv/" + path
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
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping ResultCompletionHandler) -> URLSessionDataTask? {
        
        let datatask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard
                let wSelf = self else { return }
            guard error == nil else { return completion(.error(error: error as? NSError)) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: wSelf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(.error(error: nil))
                    }
                    return
            }
            
            // Check data
            guard
                let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    completion(.success(dict: dict))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Array
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard
                let wSelf = self else { return }
            guard
                error == nil else { return completion(.error(error: error as? NSError)) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: wSelf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(.error(error: nil))
                    }
                    
                    return
            }
            
            // Check data
            guard
                let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [RawJSON] {
                    completion(.success(array: array))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Success / Failure
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTask? {
        let datatask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { return completion(.fail) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code else {
                return completion(.fail)
            }
            
            // Check data
            guard data != nil else { return completion(.fail) }
            
            completion(.success)
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Comments
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ArrayCompletionHandler = { (result: ArrayResultType) -> Void in
            
            switch result {
            case .success(let array):
                let comments: [Comment] = initEach(array)
                completion(.success(comments: comments))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Cast and crew
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
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
                    
                    if let members = jsonCrew["directing"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["writing"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["production"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["crew"] as? [RawJSON] { addMembers(members) }
//                    if let members = jsonCrew["camera"] as? [RawJSON] { addMembers(members) }
//                    if let members = jsonCrew["sound"] as? [RawJSON] { addMembers(members) }
                }
                
                // Cast
                if let members = dict["cast"] as? [[String: AnyObject]] {
                    cast += initEach(members)
                }
                
                completion(.success(cast: cast, crew: crew))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    // Generic array of Trakt objects
    func performRequest<T: TraktProtocol>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectResultType<T>) -> Void)) -> URLSessionDataTask? {
        
        let aCompletion: ResultCompletionHandler = { (result) -> Void in
            switch result {
            case .success(let dict):
                guard
                    let traktObject = T(json: dict) else { return completion(.error(error: nil)) }
                completion(.success(object: traktObject))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Array of TraktProtocol objects
    func performRequest<T: TraktProtocol>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard
                let wSelf = self else { return }
            guard
                error == nil else { return completion(.error(error: error as? NSError)) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: wSelf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(.error(error: nil))
                    }
                    
                    return
            }
            
            // Check data
            guard
                let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [RawJSON] {
                    let objects: [T] = initEach(array)
                    completion(.success(objects: objects))
                }
                else {
                    completion(.error(error: nil))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    // Hidden Items
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping HiddenItemsCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ArrayCompletionHandler = { (result: ArrayResultType) -> Void in
            
            switch result {
            case .success(let array):
                let items: [HiddenItem] = initEach(array)
                completion(.success(items: items))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
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
                let wSelf = self else { return }
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
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "signedInToTrakt"), object: nil)
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
                let wSelf = self else { return }
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
                    
                    wSelf.accessToken = accessTokenDict["access_token"] as? String
                    wSelf.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print(accessTokenDict)
                        print("[\(#function)] Access token is \(wSelf.accessToken)")
                        print("[\(#function)] Refresh token is \(wSelf.refreshToken)")
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
