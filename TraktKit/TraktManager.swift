//
//  TraktManager.swift
//  TVShows
//
//  Created by Maximilian Litteral on 2/4/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation
import UIKit

public enum searchType: String {
    case Movie = "movie"
    case Show = "show"
    case Episode = "episode"
    case Person = "person"
    case List = "list"
}

public enum watchedType: String {
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
// TODO: Make a struct
public enum statusCodes: Int {
    case success = 200
    case successNewResourceCreated = 201
    case successNoContentToReturn = 204
    case badRequestion = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotFound = 405
    case conflict = 409
    case preconditionFailed = 412
    case unprocessableEntity = 422
    case rateLimitExceeded = 429
    case serverError = 500
    case serviceOverloaded = 503
    case cloudflareError = 520
    case cloudflareError2 = 521
    case cloudflareError3 = 522
}

public class TraktManager {
    
    // MARK: Internal
    let clientID = "XXXXX"
    let clientSecret = "YYYYY"
    let callbackURL = "ZZZZZ"
    
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
    public let oauthURL: NSURL?
    
    // TODO: Move to app code so this framework can be public
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
                print("Saved access token: \(succeeded)")
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
                print("Saved refresh token: \(succeeded)")
            }
        }
    }
    
    // Completion handlers
    public typealias arrayCompletionHandler = (objects: [[String: AnyObject]]?, error: NSError?) -> Void
    public typealias dictionaryCompletionHandler = (dictionary: [String: AnyObject]?, error: NSError?) -> Void
    public typealias successCompletionHandler = (success: Bool) -> Void
    
    // MARK: - Lifecycle
    
    private init() {
        oauthURL = NSURL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(callbackURL)")
    }
    
    // MARK: - Actions
    
    public func mutableRequestForURL(URL: NSURL?, authorization: Bool, HTTPMethod: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = HTTPMethod
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        if authorization {
            request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - Authentication
    
    public func getTokenFromAuthorizationCode(code: String, completionHandler: successCompletionHandler) {
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "POST")
        let httpBodyString = "{\"code\": \"\(code)\", \"client_id\": \"\(clientID)\", \"client_secret\": \"\(clientSecret)\", \"redirect_uri\": \"\(callbackURL)\", \"grant_type\": \"authorization_code\" }"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completionHandler(success: false)
                
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                completionHandler(success: false)
                return
            }
            
            do {
                if let accessTokenDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    
                    #if DEBUG
                        print(accessTokenDict)
                    #endif
                    
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
                    print("REFRESH!")
                    self.getAccessTokenFromRefreshToken()
            }
            else {
                print("[\(__FUNCTION__)] We're good!")
            }
        }
    }
    
    public func getAccessTokenFromRefreshToken() {
        guard let rToken = refreshToken else {
            #if DEBUG
                print("[\(__FUNCTION__)] Refresh token is nil")
            #endif
            return
        }
        
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "POST")
        let httpBodyString = "{\"refresh_token\": \"\(rToken)\", \"client_id\": \"\(clientID)\", \"client_secret\": \"\(clientSecret)\", \"redirect_uri\": \"\(callbackURL)\", \"grant_type\": \"refresh_token\" }"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                
                return
            }
            
            do {
                if let accessTokenDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    
                    print(accessTokenDict)
                    
                    self.accessToken = accessTokenDict["access_token"] as? String
                    self.refreshToken = accessTokenDict["refresh_token"] as? String
                    
                    print("[\(__FUNCTION__)] Access token is \(self.accessToken)")
                    print("[\(__FUNCTION__)] Refresh token is \(self.refreshToken)")
                    
                    // Save expiration date
                    let timeInterval = accessTokenDict["expires_in"] as! NSNumber
                    let expiresDate = NSDate(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    NSUserDefaults.standardUserDefaults().setObject(expiresDate, forKey: "accessTokenExpirationDate")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
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
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }.resume()
    }
    
    // MARK: - Checkin
    
    public func checkIn(movie movie: String?, episode: String?) {
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
        jsonString += "\"app_version\": \"1.0\","
        jsonString += "\"app_date\": \"YYYY-MM-dd\""
        jsonString += "}" // End
        
        print(jsonString)
        /*let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let URLString = "https://api-v2launch.trakt.tv/checkin"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            if (response as NSHTTPURLResponse).statusCode != 201 {
                print(response)
                return
            }
            
            
        }).resume()*/
    }
    
    public func deleteActiveCheckins() {
        // Request
        let URLString = "https://api-v2launch.trakt.tv/checkin"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "DELETE")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.successNewResourceCreated.rawValue {
                print(response)
                return
            }
        }.resume()
    }
    
    // MARK: - Comments
    
    public func postComment(movie movie: String?, episode: String?, comment: String, isSpoiler spoiler: Bool, isReview review: Bool) {
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
        jsonString += "\"comment\": \"\(comment)\","
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
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.successNewResourceCreated.rawValue else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }.resume()
    }
    
    // MARK: - Search
    
    /// Perform a text query that searches titles, descriptions, translated titles, aliases, and people.
    /// Status Code: 200
    ///
    /// :param: query The string to search by
    /// :param: type The type of search
    public func search(query: String, type: searchType, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/search?query=\(query)&type=\(type.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else  {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
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
        
        }.resume()
    }
    
    // MARK: - Ratings
    
    /// Returns rating (between 0 and 10) and distribution for a movie / show / episode.
    /// Status Code: 200
    ///
    /// :param: which type of content to receive
    /// :param: trakt ID for movie / show / episode
    /// :param: completion handler
    public func getRatings(type: watchedType, id: NSNumber, extended: extendedType = .Min, completion: dictionaryCompletionHandler) {
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
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error)")
                #endif
                
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
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
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
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
    public func getWatched(type: watchedType, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/sync/watched/\(type.rawValue)"
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
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(response)")
                #endif
                
                completion(objects: [], error: nil)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
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
        jsonString += ",".join(movies) // Add Movies
        jsonString += "]," // End Movies
        jsonString += "\"shows\": [" // Begin Shows
        jsonString += ",".join(shows) // Add Shows
        jsonString += "]," // End Shows
        jsonString += "\"episodes\": [" // Begin Episodes
        jsonString += ",".join(episodes) // Add Episodes
        jsonString += "]" // End Episodes
        jsonString += "}" // End
        
        print(jsonString)
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
            
            // A successful post request sends a 201 status code
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.successNewResourceCreated.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
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
        jsonString += ",".join(movies) // Add Movies
        jsonString += "]," // End Movies
        jsonString += "\"shows\": [" // Begin Shows
        jsonString += ",".join(shows) // Add Shows
        jsonString += "]," // End Shows
        jsonString += "\"episodes\": [" // Begin Episodes
        jsonString += ",".join(episodes) // Add Episodes
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
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
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
