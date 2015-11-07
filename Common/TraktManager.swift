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

public enum WatchedType: String {
    case Movies = "movies"
    case Shows = "shows"
    case Episodes = "episodes"
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
    public typealias arrayCompletionHandler = (objects: [[String: AnyObject]]?, error: NSError?) -> Void
    public typealias dictionaryCompletionHandler = (dictionary: [String: AnyObject]?, error: NSError?) -> Void
    public typealias successCompletionHandler = (success: Bool) -> Void
    
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
            NSLocalizedDescriptionKey: "",
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
    
    // MARK: - Checkin
    
    public func checkIn(movie movie: String?, episode: String?, completionHandler: successCompletionHandler) {
        // JSON
        var jsonString = String()

        jsonString += "{" // Beginning
        if let movie = movie {
            jsonString += "\"movie\":" // Begin Movie
            jsonString += movie // Add Movie
            jsonString += "," // End Movie
        }
        else if let episode = episode {
            jsonString += "\"episode\": " // Begin Episode
            jsonString += episode // Add Episode
            jsonString += "," // End Episode
        }
        jsonString += "\"app_version\": \"1.1.1\","
        jsonString += "\"app_date\": \"2015-11-18\""
        jsonString += "}" // End
        
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let URLString = "https://api-v2launch.trakt.tv/checkin"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completionHandler(success: false)
                return
            }
            
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where (HTTPResponse.statusCode == statusCodes.successNewResourceCreated ||
                    HTTPResponse.statusCode == statusCodes.conflict) else {
                        #if DEBUG
                            print("[\(__FUNCTION__)] \(response)")
                        #endif
                        completionHandler(success: false)
                        return
            }
            
            if HTTPResponse.statusCode == statusCodes.successNewResourceCreated {
                // Started watching
                completionHandler(success: true)
            }
            else {
                // Already watching something
                #if DEBUG
                    print("[\(__FUNCTION__)] Already watching a show")
                #endif
                completionHandler(success: false)
            }
            
            
        }).resume()
    }
    
    public func deleteActiveCheckins(completionHandler: successCompletionHandler) {
        // Request
        let URLString = "https://api-v2launch.trakt.tv/checkin"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "DELETE")
        
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
                where HTTPResponse.statusCode == statusCodes.successNoContentToReturn else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    completionHandler(success: false)
                    return
            }
            
            print("Cancelled check-in")
            
            completionHandler(success: true)
        }.resume()
    }
    
    // MARK: - Comments
    
    public func postComment(movie movie: String?, show: String?, episode: String?, comment: String, isSpoiler spoiler: Bool, isReview review: Bool, completionHandler: successCompletionHandler) {
        // JSON
        var jsonString = String()
        
        jsonString += "{" // Beginning
        if let movie = movie {
            jsonString += "\"movie\":" // Begin Movie
            jsonString += movie // Add Movie
            jsonString += "," // End Movie
        }
        else if let show = show {
            jsonString += "\"show\":" // Begin Show
            jsonString += show // Add Show
            jsonString += "," // End Show
        }
        else if let episode = episode {
            jsonString += "\"episode\": " // Begin Episode
            jsonString += episode // Add Episode
            jsonString += "," // End Episode
        }
        let fixedComment = comment.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        jsonString += "\"comment\": \"\(fixedComment)\","
        jsonString += "\"spoiler\": \(spoiler),"
        jsonString += "\"review\": \(review)"
        jsonString += "}" // End
        
        #if DEBUG
            print(jsonString)
        #endif
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let URLString = "https://api-v2launch.trakt.tv/comments"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
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
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
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
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completionHandler(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completionHandler(success: false)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                completionHandler(success: false)
            }
        }.resume()
    }
    
    // MARK: - Search
    
    /// Perform a text query that searches titles, descriptions, translated titles, aliases, and people.
    /// Status Code: 200
    ///
    /// :param: query The string to search by
    /// :param: type The type of search
    public func search(query: String, types: [SearchType], completion: arrayCompletionHandler) -> NSURLSessionDataTask {
        
        let typesString = types.map { $0.rawValue }.joinWithSeparator(",")
        
        let urlString = "https://api-v2launch.trakt.tv/search?query=\(query)&type=\(typesString)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
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
                where HTTPResponse.statusCode == statusCodes.success else  {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
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
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Lookup an item by using a trakt ID or other external ID. This is helpful to get an items info including the trakt ID.
    /// Status Code: 200
    public func lookup(id: String, idType: LookupType, completion: arrayCompletionHandler) -> NSURLSessionTask {
        
        let urlString = "https://api-v2launch.trakt.tv/search?id_type=\(idType.rawValue)&id=\(id)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")

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
                where HTTPResponse.statusCode == statusCodes.success else  {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                completion(objects: nil, error: nil)
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
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    // MARK: - Ratings
    
    /// Returns rating (between 0 and 10) and distribution for a movie / show / episode.
    /// Status Code: 200
    ///
    /// :param: which type of content to receive
    /// :param: trakt ID for movie / show / episode
    /// :param: completion handler
    public func getRatings(type: WatchedType, id: NSNumber, extended: extendedType = .Min, completion: dictionaryCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/movies/\(id)/ratings"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
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

    // MARK: - Sync
    
    /// Returns dictionary of dates when content was last updated
    /// Status Code: 200
    ///
    /// :param: completion handler
    public func lastActivities(completion: dictionaryCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/sync/last_activities"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
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
                    print("[\(__FUNCTION__)] \(response)")
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
                    print(jsonSerializationError)
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
    
    /// Returns all movies or shows a user has watched.
    /// Status Code: 200
    ///
    /// :param: which type of content to receive
    /// :param: completion handler
    public func getWatched(type: WatchedType, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/sync/watched/\(type.rawValue)"
//        let urlString = "https://api-v2launch.trakt.tv/users/fvkey/watched/shows?extended=full" // Use this to test show sync with
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                
                completion(objects: [], error: nil)
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
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }.resume()
    }
    
    /// Add items to a user's watch history.
    /// Status Code: 201
    ///
    /// :param: array of movie objects
    /// :param: array of show objects
    /// :param: array of episode objects
    /// :param: completion handler
    public func addToHistory(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) {
        // JSON
        var jsonString = String()
        
        jsonString += "{" // Beginning
        jsonString += "\"movies\": [" // Begin Movies
        jsonString += movies.joinWithSeparator(",") // Add Movies
        jsonString += "]," // End Movies
        jsonString += "\"shows\": [" // Begin Shows
        jsonString += shows.joinWithSeparator(",") // Add Shows
        jsonString += "]," // End Shows
        jsonString += "\"episodes\": [" // Begin Episodes
        jsonString += episodes.joinWithSeparator(",") // Add Episodes
        jsonString += "]" // End Episodes
        jsonString += "}" // End
        
        #if DEBUG
            print(jsonString)
        #endif
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let urlString = "https://api-v2launch.trakt.tv/sync/history"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                #if DEBUG
                    print(response)
                #endif
                completion(success: false)
                return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                completion(success: false)
            }
        }.resume()
    }
    
    /// Removes items from a user's watch history including watches, scrobbles, and checkins.
    /// Status Code: 200
    ///
    /// :param: array of movie objects
    /// :param: array of show objects
    /// :param: array of episode objects
    /// :param: completion handler
    public func removeFromHistory(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) {
        // JSON
        var jsonString = String()
        
        jsonString += "{" // Beginning
        jsonString += "\"movies\": [" // Begin Movies
        jsonString += movies.joinWithSeparator(",") // Add Movies
        jsonString += "]," // End Movies
        jsonString += "\"shows\": [" // Begin Shows
        jsonString += shows.joinWithSeparator(",") // Add Shows
        jsonString += "]," // End Shows
        jsonString += "\"episodes\": [" // Begin Episodes
        jsonString += episodes.joinWithSeparator(",") // Add Episodes
        jsonString += "]" // End Episodes
        jsonString += "}" // End
        
        print(jsonString)
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let urlString = "https://api-v2launch.trakt.tv/sync/history/remove"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print(response)
                #endif
                completion(success: false)
                return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: true)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                
                completion(success: false)
            }
        }.resume()
    }
}
