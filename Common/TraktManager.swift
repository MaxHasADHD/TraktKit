//
//  TraktManager.swift
//  TVShows
//
//  Created by Maximilian Litteral on 2/4/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

// Errors
internal let userInfo = [
    "title": "Trakt",
    NSLocalizedDescriptionKey: "No data returned",
    NSLocalizedFailureReasonErrorKey: "",
    NSLocalizedRecoverySuggestionErrorKey: ""
]
let TraktKitNoDataError = NSError(domain: "com.litteral.TraktKit", code: -10, userInfo: userInfo)

// Enums

public enum Method: String {
    /// Select one or more items. Success returns 200 status code.
    case GET
    /// Create a new item. Success returns 201 status code.
    case POST
    /// Update an item. Success returns 200 status code.
    case PUT
    /// Delete an item. Success returns 200 or 204 status code.
    case DELETE
}

public struct StatusCodes {
    /// Success
    public static let Success = 200
    /// Success - new resource created (POST)
    public static let SuccessNewResourceCreated = 201
    /// Success - no content to return (DELETE)
    public static let SuccessNoContentToReturn = 204
    /// Bad Request - request couldn't be parsed
    public static let BadRequestion = 400
    /// Unauthorized - OAuth must be provided
    public static let Unauthorized = 401
    /// Forbidden - invalid API key or unapproved app
    public static let Forbidden = 403
    /// Not Found - method exists, but no record found
    public static let NotFound = 404
    /// Method Not Found - method doesn't exist
    public static let MethodNotFound = 405
    /// Conflict - resource already created
    public static let Conflict = 409
    /// Precondition Failed - use application/json content type
    public static let PreconditionFailed = 412
    /// Unprocessable Entity - validation errors
    public static let UnprocessableEntity = 422
    /// Rate Limit Exceeded
    public static let RateLimitExceeded = 429
    /// Server Error
    public static let ServerError = 500
    /// Service Unavailable - server overloaded
    public static let ServiceOverloaded = 503
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError = 520
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError2 = 521
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError3 = 522
}

public enum SearchType: String {
    case Movie = "movie"
    case Show = "show"
    case Episode = "episode"
    case Person = "person"
    case List = "list"
}

public enum LookupType: String {
    case TraktMovie = "trakt-movie"
    case TraktShow = "trakt-show"
    case TraktEpisode = "trakt-episode"
    case IMDB = "imdb"
    case TMDB = "tmdb"
    case TVDB = "tvdb"
    case TVRage = "tvrage"
}

public enum Type: String, CustomStringConvertible {
    case Movies = "movies"
    case Shows = "shows"
    
    public var description: String {
        return self.rawValue
    }
}

public enum WatchedType: String, CustomStringConvertible {
    case Movies = "movies"
    case Shows = "shows"
    case Seasons = "seasons"
    case Episodes = "episodes"
    
    public var description: String {
        return self.rawValue
    }
}

public enum Type2: String, CustomStringConvertible {
    case All = "all"
    case Movies = "movies"
    case Shows = "shows"
    case Seasons = "seasons"
    case Episodes = "episodes"
    case Lists = "lists"
    
    public var description: String {
        return self.rawValue
    }
}

public enum CommentType: String {
    case All = "all"
    case Reviews = "reviews"
    case Shouts = "shouts"
}

public enum extendedType: String {
    case Min = "min"
    case Images = "images"
    case Full = "full"
    case FullAndImages = "full,images"
    case Metadata = "metadata"
    case Episodes = "episodes" // For getting all seasons and episodes
    case FullAndEpisodes = "full,episodes"
    case FullAndEpisodesAndImages = "full,episodes,images"
}

public class TraktManager {
    
    // TODO List:
    // 1. Create a limit object, double check every paginated API call is marked as paginated
    
    // MARK: Internal
    private var clientID: String?
    private var clientSecret: String?
    private var redirectURI: String?
    
    // Keys
    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"
    
    // Lazy
    lazy var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // MARK: Public
    public static let sharedManager = TraktManager()
    
    public var isSignedIn: Bool {
        get {
            return accessToken != nil
        }
    }
    public var oauthURL: NSURL?
    
    public var accessToken: String? {
        get {
            if let accessTokenData = MLKeychain.loadData(forKey: accessTokenKey) {
                if let accessTokenString = NSString(data: accessTokenData, encoding: NSUTF8StringEncoding) as? String {
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
            }
            else {
                // Save to keychain
                let succeeded = MLKeychain.setString(newValue!, forKey: accessTokenKey)
                #if DEBUG
                    print("Saved access token: \(succeeded)")
                #endif
            }
        }
    }
    
    public var refreshToken: String? {
        get {
            if let refreshTokenData = MLKeychain.loadData(forKey: refreshTokenKey) {
                if let accessTokenString = NSString(data: refreshTokenData, encoding: NSUTF8StringEncoding) as? String {
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
            }
            else {
                // Save to keychain
                let succeeded = MLKeychain.setString(newValue!, forKey: refreshTokenKey)
                #if DEBUG
                    print("Saved refresh token: \(succeeded)")
                #endif
            }
        }
    }
    
    // MARK: Result Types
    public enum DictionaryResultType {
        case Success(dict: RawJSON)
        case Error(error: NSError?)
    }
    
    public enum SuccessResultType {
        case Success
        case Fail
    }
    
    public enum ArrayResultType {
        case Success(array: [RawJSON])
        case Error(error: NSError?)
    }
    
    public enum CommentsResultType {
        case Success(comments: [Comment])
        case Error(error: NSError?)
    }
    
    public enum CastCrewResultType {
        case Success(cast: [CastMember], crew: [CrewMember])
        case Error(error: NSError?)
    }
    
    // MARK: Completion handlers
    public typealias ResultCompletionHandler        = (result: DictionaryResultType) -> Void
    public typealias SuccessCompletionHandler       = (result: SuccessResultType) -> Void
    public typealias ArrayCompletionHandler         = (result: ArrayResultType) -> Void
    public typealias CommentsCompletionHandler      = (result: CommentsResultType) -> Void
    public typealias CastCrewCompletionHandler      = (result: CastCrewResultType) -> Void
    
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
        
        self.oauthURL = NSURL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)")
    }
    
    internal func createTraktErrorWithStatusCode(statusCode: Int) -> NSError {
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
    
    public func mutableRequestForURL(URL: NSURL?, authorization: Bool, HTTPMethod: Method) -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = HTTPMethod.rawValue
        
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
    
    public func mutableRequestForURL(path: String, authorization: Bool, HTTPMethod: Method) -> NSMutableURLRequest? {
        let urlString = "https://api-v2launch.trakt.tv/" + path
        guard let URL = NSURL(string: urlString) else {
            return nil
        }
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod.rawValue
        
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
    
    func createJsonData(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON]) throws -> NSData? {
        
        let json = [
            "movies": movies,
            "shows": shows,
            "episodes": episodes,
        ]
        
        #if DEBUG
            print(json)
        #endif
        return try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
    }
    
    // MARK: Perform Requests
    
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        
        let datatask = session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
            guard let wSelf = self else { return }
            guard error == nil else { return completion(result: .Error(error: error)) }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        completion(result: .Error(error: wSelf.createTraktErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(result: .Error(error: nil))
                    }
                    return
            }
            
            // Check data
            guard let data = data else { return completion(result: .Error(error: TraktKitNoDataError)) }
            
            do {
                if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(result: .Success(dict: dict))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(result: .Error(error: jsonSerializationError))
            }
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Array
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        let dataTask = session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
            guard let wSelf = self else { return }
            guard error == nil else { return completion(result: .Error(error: error)) }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        completion(result: .Error(error: wSelf.createTraktErrorWithStatusCode(HTTPResponse.statusCode)))
                    }
                    else {
                        completion(result: .Error(error: nil))
                    }
                    
                    return
            }
            
            // Check data
            guard let data = data else { return completion(result: .Error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [RawJSON] {
                    completion(result: .Success(array: array))
                }
            }
            catch let jsonSerializationError as NSError {
                completion(result: .Error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Success / Failure
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        let datatask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else { return completion(result: .Fail) }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == code else { return completion(result: .Fail) }
            
            // Check data
            guard data != nil else { return completion(result: .Fail) }
            
            completion(result: .Success)
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Comments
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: CommentsCompletionHandler) -> NSURLSessionDataTask? {
        let aCompletion: ArrayCompletionHandler = { (result: ArrayResultType) -> Void in
            
            switch result {
            case .Success(let array):
                var comments: [Comment] = []
                
                for jsonComment in array {
                    let comment = Comment(json: jsonComment)
                    
                    comments.append(comment)
                }
                
                completion(result: .Success(comments: comments))
            case .Error(let error):
                completion(result: .Error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: aCompletion)
        
        return dataTask
    }
    
    /// Cast and crew
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: CastCrewCompletionHandler) -> NSURLSessionDataTask? {
        let aCompletion: ResultCompletionHandler = { (result: DictionaryResultType) -> Void in
            switch result {
            case .Success(let dict):
                var crew: [CrewMember] = []
                var cast: [CastMember] = []
                
                // Crew
                if let jsonCrew = dict["crew"] as? RawJSON {
                    
                    func addMembers(members: [RawJSON]) {
                        members.forEach { (dict) in
                            let crewMember = CrewMember(json: dict)
                            crew.append(crewMember)
                        }
                    }
                    
                    if let members = jsonCrew["production"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["writing"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["crew"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["camera"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["sound"] as? [RawJSON] { addMembers(members) }
                }
                
                // Cast
                if let members = dict["cast"] as? [[String: AnyObject]] {
                    members.forEach { (dict) in
                        let castMember = CastMember(json: dict)
                        cast.append(castMember)
                    }
                }
                
                completion(result: .Success(cast: cast, crew: crew))
            case .Error(let error):
                completion(result: .Error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: aCompletion)
        
        return dataTask
    }
    
    // MARK: - Authentication
    
    public func getTokenFromAuthorizationCode(code: String, completionHandler: SuccessCompletionHandler?) throws {
        guard let clientID = clientID,
            clientSecret = clientSecret,
            redirectURI = redirectURI else {
                completionHandler?(result: .Fail)
                return
        }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        guard let request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else {
            completionHandler?(result: .Fail)
            return
        }
        
        let json = [
            "code": code,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
        ]
        
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        
        let dataTask = session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
            guard let wSelf = self else { return }
            guard error == nil else {
                completionHandler?(result: .Fail)
                
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == StatusCodes.Success else {
                    completionHandler?(result: .Fail)
                    return
            }
            
            // Check data
            guard let data = data else {
                completionHandler?(result: .Fail)
                return
            }
            
            do {
                if let accessTokenDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    
                    wSelf.accessToken = accessTokenDict["access_token"] as? String
                    wSelf.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print("[\(#function)] Access token is \(wSelf.accessToken)")
                        print("[\(#function)] Refresh token is \(wSelf.refreshToken)")
                    #endif
                    
                    // Save expiration date
                    let timeInterval = accessTokenDict["expires_in"] as! NSNumber
                    let expiresDate = NSDate(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    NSUserDefaults.standardUserDefaults().setObject(expiresDate, forKey: "accessTokenExpirationDate")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    // Post notification
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName("signedInToTrakt", object: nil)
                    })
                    
                    completionHandler?(result: .Success)
                }
            }
            catch {
                completionHandler?(result: .Fail)
            }
        }
        dataTask.resume()
    }
    
    // MARK: Refresh access token
    
    public func needToRefresh() -> Bool {
        if let expirationDate = NSUserDefaults.standardUserDefaults().objectForKey("accessTokenExpirationDate") as? NSDate {
            let today = NSDate()
            
            if today.compare(expirationDate) == .OrderedDescending ||
                today.compare(expirationDate) == .OrderedSame {
                    return true
            }
            else {
                return false
            }
        }
        
        return false
    }
    
    public func checkToRefresh() throws {
        if let expirationDate = NSUserDefaults.standardUserDefaults().objectForKey("accessTokenExpirationDate") as? NSDate {
            let today = NSDate()
            
            if today.compare(expirationDate) == .OrderedDescending ||
                today.compare(expirationDate) == .OrderedSame {
                    #if DEBUG
                        print("[\(#function)] Refreshing token!")
                    #endif
                    try self.getAccessTokenFromRefreshToken({ (success) -> Void in
                        
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
            redirectURI = redirectURI else { return completionHandler(result: .Fail) }
        
        guard let rToken = refreshToken else { return completionHandler(result: .Fail) }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        guard let request = mutableRequestForURL(url, authorization: false, HTTPMethod: .POST) else { return completionHandler(result: .Fail) }
        
        let json = [
            "refresh_token": rToken,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "refresh_token",
        ]
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else { return completionHandler(result: .Fail) }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == StatusCodes.Success else { return completionHandler(result: .Fail) }
            
            // Check data
            guard let data = data else { return completionHandler(result: .Fail) }
            
            do {
                if let accessTokenDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    
        
                    self.accessToken = accessTokenDict["access_token"] as? String
                    self.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print(accessTokenDict)
                        print("[\(#function)] Access token is \(self.accessToken)")
                        print("[\(#function)] Refresh token is \(self.refreshToken)")
                    #endif
                    
                    // Save expiration date
                    guard let timeInterval = accessTokenDict["expires_in"] as? NSNumber else { return completionHandler(result: .Fail) }
                    let expiresDate = NSDate(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    NSUserDefaults.standardUserDefaults().setObject(expiresDate, forKey: "accessTokenExpirationDate")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    completionHandler(result: .Success)
                    
                    // Post notification
//                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                        NSNotificationCenter.defaultCenter().postNotificationName("signedInToTrakt", object: nil)
//                    })
                }
            }
            catch let jsonSerializationError as NSError {
                completionHandler(result: .Fail)
            }
        }.resume()
    }
}
