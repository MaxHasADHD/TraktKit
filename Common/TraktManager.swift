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
}

public struct statusCodes {
    public static let success = 200
    public static let successNewResourceCreated = 201
    public static let successNoContentToReturn = 204
    public static let badRequestion = 400
    public static let unauthorized = 401
    public static let forbidden = 403
    public static let notFound = 404
    public static let methodNotFound = 405
    public static let conflict = 409
    public static let preconditionFailed = 412
    public static let unprocessableEntity = 422
    public static let rateLimitExceeded = 429
    public static let serverError = 500
    public static let serviceOverloaded = 503
    public static let cloudflareError = 520
    public static let cloudflareError2 = 521
    public static let cloudflareError3 = 522
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
    
    // Completion handlers
    public typealias arrayCompletionHandler         = (objects: [[String: AnyObject]]?, error: NSError?) -> Void
    public typealias dictionaryCompletionHandler    = (dictionary: [String: AnyObject]?, error: NSError?) -> Void
    public typealias successCompletionHandler       = (success: Bool) -> Void
    public typealias commentsCompletionHandler      = ((comments: [Comment], error: NSError?) -> Void)
    public typealias CastCrewCompletionHandler      = ((cast: [CastMember], crew: [CrewMember], error: NSError?) -> Void)
    
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
        let TraktKitIncorrectStatusError = NSError(domain: "com.litteral.TraktKit", code: -1400, userInfo: userInfo)
        
        return TraktKitIncorrectStatusError
    }
    
    // MARK: - Actions
    
    public func mutableRequestForURL(URL: NSURL?, authorization: Bool, HTTPMethod: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = HTTPMethod
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        if let clientID = clientID {
            request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        }
        if authorization {
            request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    public func mutableRequestForURL(path: String, authorization: Bool, HTTPMethod: String) -> NSMutableURLRequest? {
        let urlString = "https://api-v2launch.trakt.tv/" + path
        guard let URL = NSURL(string: urlString) else {
            return nil
        }
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod
        
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
    
    func createJsonData(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON]) -> NSData? {
        
        let json = [
            "movies": movies,
            "shows": shows,
            "episodes": episodes,
        ]
        
        #if DEBUG
            print(json)
        #endif
        return try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
    }
    
    // MARK: Perform Requests
    
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    #if DEBUG
                        print(response)
                    #endif
                    
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        completion(objects: nil, error: self.createTraktErrorWithStatusCode(HTTPResponse.statusCode))
                    }
                    else {
                        completion(objects: nil, error: nil)
                    }
                    
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(objects: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: array, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        let datatask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(dictionary: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    #if DEBUG
                        print(response)
                    #endif
                    
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        completion(dictionary: nil, error: self.createTraktErrorWithStatusCode(HTTPResponse.statusCode))
                    }
                    else {
                        completion(dictionary: nil, error: nil)
                    }
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(dictionary: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: dict, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(dictionary: nil, error: jsonSerializationError)
            }
        }
        datatask.resume()
        
        return datatask
    }
    
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        let datatask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completion(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == code else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    
                    completion(success: false)
                    
                    return
            }
            
            completion(success: true)
        }
        datatask.resume()
        
        return datatask
    }
    
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: commentsCompletionHandler) -> NSURLSessionDataTask? {
        let aCompletion: arrayCompletionHandler = { (objects: [[String: AnyObject]]?, error: NSError?) -> Void in
            
            if let objects = objects {
                var comments: [Comment] = []
                
                for jsonComment in objects {
                    let comment = Comment(json: jsonComment)
                    
                    comments.append(comment)
                }
                
                completion(comments: comments, error: error)
            }
            else {
                completion(comments: [], error: error)
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: statusCodes.success, completion: aCompletion)
        
        return dataTask
    }
    
    func performRequest(request request: NSURLRequest, expectingStatusCode code: Int, completion: CastCrewCompletionHandler) -> NSURLSessionDataTask? {
        let aCompletion: dictionaryCompletionHandler = { (json: [String: AnyObject]?, error: NSError?) -> Void in
            
            if let json = json {
                var crew: [CrewMember] = []
                var cast: [CastMember] = []
                
                // Crew
                if let jsonCrew = json["crew"] as? [String: AnyObject],
                    productionCrew = jsonCrew["production"]  as? [[String: AnyObject]] {
                    for jsonCrewMember in productionCrew {
                        let crewMember = CrewMember(json: jsonCrewMember)
                        
                        crew.append(crewMember)
                    }
                }
                
                // Cast
                if let jsonCast = json["cast"] as? [[String: AnyObject]] {
                    for jsonCastMember in jsonCast {
                        let castMember = CastMember(json: jsonCastMember)
                        
                        cast.append(castMember)
                    }
                }
                
                completion(cast: cast, crew: crew, error: error)
            }
            else {
                completion(cast: [], crew: [], error: error)
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: statusCodes.success, completion: aCompletion)
        
        return dataTask
    }
    
    // MARK: - Authentication
    
    public func getTokenFromAuthorizationCode(code: String, completionHandler: successCompletionHandler?) {
        guard let clientID = clientID,
            clientSecret = clientSecret,
            redirectURI = redirectURI else {
                completionHandler?(success: false)
                return
        }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "POST")
        let httpBodyString = "{\"code\": \"\(code)\", \"client_id\": \"\(clientID)\", \"client_secret\": \"\(clientSecret)\", \"redirect_uri\": \"\(redirectURI)\", \"grant_type\": \"authorization_code\" }"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completionHandler?(success: false)
                
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                completionHandler?(success: false)
                return
            }
            
            // Check data
            guard let data = data else {
                completionHandler?(success: false)
                return
            }
            
            do {
                if let accessTokenDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    
                    self.accessToken = accessTokenDict["access_token"] as? String
                    self.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print("[\(__FUNCTION__)] Access token is \(self.accessToken)")
                        print("[\(__FUNCTION__)] Refresh token is \(self.refreshToken)")
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
                    
                    completionHandler?(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completionHandler?(success: false)
            }
        }.resume()
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
    
    public func checkToRefresh() {
        if let expirationDate = NSUserDefaults.standardUserDefaults().objectForKey("accessTokenExpirationDate") as? NSDate {
            let today = NSDate()
            
            if today.compare(expirationDate) == .OrderedDescending ||
                today.compare(expirationDate) == .OrderedSame {
                    #if DEBUG
                        print("[\(__FUNCTION__)] Refreshing token!")
                    #endif
                    self.getAccessTokenFromRefreshToken({ (success) -> Void in
                        
                    })
            }
            else {
                #if DEBUG
                    print("[\(__FUNCTION__)] No need to refresh token!")
                #endif
            }
        }
    }
    
    public func getAccessTokenFromRefreshToken(completionHandler: successCompletionHandler) {
        guard let clientID = clientID,
            clientSecret = clientSecret,
            redirectURI = redirectURI else {
                return
        }
        
        guard let rToken = refreshToken else {
            #if DEBUG
                print("[\(__FUNCTION__)] Refresh token is nil")
            #endif
            completionHandler(success: false)
            return
        }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "POST")
        let httpBodyString = "{\"refresh_token\": \"\(rToken)\", \"client_id\": \"\(clientID)\", \"client_secret\": \"\(clientSecret)\", \"redirect_uri\": \"\(redirectURI)\", \"grant_type\": \"refresh_token\" }"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completionHandler(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                completionHandler(success: false)
                return
            }
            
            // Check data
            guard let data = data else {
                completionHandler(success: false)
                return
            }
            
            do {
                if let accessTokenDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    
                    
                    
                    self.accessToken = accessTokenDict["access_token"] as? String
                    self.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    #if DEBUG
                        print(accessTokenDict)
                        print("[\(__FUNCTION__)] Access token is \(self.accessToken)")
                        print("[\(__FUNCTION__)] Refresh token is \(self.refreshToken)")
                    #endif
                    
                    // Save expiration date
                    guard let timeInterval = accessTokenDict["expires_in"] as? NSNumber else {
                        completionHandler(success: false)
                        return
                    }
                    let expiresDate = NSDate(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    NSUserDefaults.standardUserDefaults().setObject(expiresDate, forKey: "accessTokenExpirationDate")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    completionHandler(success: true)
                    
                    // Post notification
//                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                        NSNotificationCenter.defaultCenter().postNotificationName("signedInToTrakt", object: nil)
//                    })
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                
                completionHandler(success: false)
            }
        }.resume()
    }
    
    // MARK: - Ratings
    
    /// Returns rating (between 0 and 10) and distribution for a movie / show / episode.
    /// Status Code: 200
    ///
    /// :param: which type of content to receive
    /// :param: trakt ID for movie / show / episode
    /// :param: completion handler
    public func getRatings(type: WatchedType, id: NSNumber, extended: extendedType = .Min, completion: dictionaryCompletionHandler) {

        guard let request = mutableRequestForURL("movies/\(id)/ratings", authorization: false, HTTPMethod: "GET") else {
            return
        }
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completion(dictionary: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error)")
                #endif
                
                return
            }
            
            // Check data
            guard let data = data else {
                completion(dictionary: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: dictionary, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(dictionary: nil, error: jsonSerializationError)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }.resume()
    }
}
