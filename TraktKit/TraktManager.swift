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

private let _SingletonASharedInstance = TraktManager()

public class TraktManager {
    
    // MARK: Internal
    let clientID = "XXXXX"
    let clientSecret = "YYYYY"
    let callbackURL = "ZZZZZ"
    lazy var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // MARK: Public
    public var isSignedIn: Bool {
        get {
            return accessToken != nil
        }
    }
    public let oauthURL: NSURL?
    // Move to app code, make it a delegate
    public var accessToken: String? {
        get {
            if let accessTokenData = MLKeychain.loadData(forKey: "accessToken") {
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
                MLKeychain.deleteItem(forKey: "accessToken")
            }
            else {
                // Save to keychain
                MLKeychain.setString(newValue!, forKey: "accessToken")
            }
        }
    }
    
    // Completion handlers
    public typealias arrayCompletionHandler = (objects: [[String: AnyObject]]?, error: NSError?) -> Void
    public typealias dictionaryCompletionHandler = (dictionary: [String: AnyObject]?, error: NSError?) -> Void
    public typealias successCompletionHandler = (success: Bool) -> Void
    
    // MARK: - Lifecycle
    
    public class var sharedManager: TraktManager{
        return _SingletonASharedInstance
    }
    
    init() {
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
    
    // MARK: Authentication
    
    public func getTokenFromAuthorizationCode(code: String) {
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "POST")
        let httpBodyString = "{\"code\": \"\(code)\", \"client_id\": \"\(clientID)\", \"client_secret\": \"\(clientSecret)\", \"redirect_uri\": \"\(callbackURL)\", \"grant_type\": \"authorization_code\" }"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            var error: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! NSDictionary
            
            if let error = error {
                println(error)
            }
            else {
                // TODO: Store the expire date
                let timeInterval = dictionary["expires_in"] as! NSNumber
                let expiresDate = NSDate(timeIntervalSinceNow: timeInterval.doubleValue)
                println(expiresDate)
                self.accessToken = dictionary["access_token"] as? String
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("signedInToTrakt", object: nil)
                })
            }
        }).resume()
    }
    
    // MARK: - Checkin
    
    public func checkIn(#movie: String?, episode: String?) {
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
        
        println(jsonString)
        /*let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let URLString = "https://api-v2launch.trakt.tv/checkin"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                return
            }
            
            if (response as NSHTTPURLResponse).statusCode != 201 {
                println(response)
                return
            }
            
            
        }).resume()*/
    }
    
    public func deleteActiveCheckins() {
        // Request
        let URLString = "https://api-v2launch.trakt.tv/checkin"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "DELETE")
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.successNewResourceCreated.rawValue {
                println(response)
                return
            }
            
            
        }).resume()
    }
    
    // MARK: - Comments
    
    public func postComment(#movie: String?, episode: String?, comment: String, isSpoiler spoiler: Bool, isReview review: Bool) {
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
        
        println(jsonString)
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let URLString = "https://api-v2launch.trakt.tv/comments"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.successNewResourceCreated.rawValue {
                println(response)
                return
            }
            
            var error: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! [String: AnyObject]
            
            if let error = error {
                println(error)
//                completion(results: nil)
            }
            else {
//                completion(results: array)
            }
        }).resume()
    }
    
    // MARK: - Search
    
    /// Searches the Trakt database for a given search type
    ///
    /// :param: query The string to search by
    /// :param: type The type of search
    /// :param: Authorization False
    ///
    /// :returns: An array of dictionaries with information about each result
    public func search(query: String, type: searchType, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/search?query=\(query)&type=\(type.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                println(error)
                completion(objects: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                println(response)
                return
            }
            
            var jsonSerializationError: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonSerializationError) as? [[String: AnyObject]]
            
            if let jsonSerializationError = jsonSerializationError {
                println(jsonSerializationError)
                completion(objects: nil, error: jsonSerializationError)
            }
            else {
                completion(objects: array, error: nil)
            }
        }).resume()
    }
    
    // MARK: - Ratings
    
    public func getRatings(type: watchedType, id: NSNumber, extended: extendedType = .Min, completion: dictionaryCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/movies/\(id)/ratings"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println(error)
                completion(dictionary: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                println(response)
                return
            }
            
            var jsonSerializationError: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonSerializationError) as? [String: AnyObject]
            
            if let jsonSerializationError = jsonSerializationError {
                println(jsonSerializationError)
                completion(dictionary: nil, error: jsonSerializationError)
            }
            else {
                completion(dictionary: dictionary, error: nil)
            }
        }).resume()
    }

    // MARK: - Sync
    
    public func lastActivities(completion: dictionaryCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/sync/last_activities"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                println("Error getting users last activities: \(error)")
                completion(dictionary: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                println(response)
                return
            }
            
            var jsonSerializationError: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonSerializationError) as? [String: AnyObject]
            
            if let jsonSerializationError = jsonSerializationError {
                println(jsonSerializationError)
                completion(dictionary: nil, error: jsonSerializationError)
            }
            else {
                completion(dictionary: dictionary, error: nil)
            }
        }).resume()
    }
    
    public func getWatched(type: watchedType, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/sync/watched/\(type.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println("Error getting users watched shows: \(error)")
                completion(objects: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                println(response)
                completion(objects: [], error: nil)
                return
            }
            
            var jsonSerializationError: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonSerializationError) as? [[String: AnyObject]]
            
            if let jsonSerializationError = jsonSerializationError {
                println(jsonSerializationError)
                completion(objects: nil, error: jsonSerializationError)
            }
            else {
                completion(objects: array, error: nil)
            }
        }).resume()
    }
    
    public func addToHistory(#movies: Array<String>, shows: Array<String>, episodes: Array<String>, completion: successCompletionHandler) {
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
        
        println(jsonString)
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let urlString = "https://api-v2launch.trakt.tv/sync/history"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println("ERROR!: \(error)")
                return
            }
            
            // A successful post request sends a 201 status code
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.successNewResourceCreated.rawValue {
                println(response)
                return
            }
            
            var error: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Dictionary<String, AnyObject>
            
            if let error = error {
                println(error)
                completion(success: false)
            }
            else {
//                println(dictionary)
                completion(success: true)
            }
        }).resume()
    }
    
    public func removeFromHistory(#movies: Array<String>, shows: Array<String>, episodes: Array<String>, completion: successCompletionHandler) {
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
        
        println(jsonString)
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        let urlString = "https://api-v2launch.trakt.tv/sync/history/remove"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "POST")
        request.HTTPBody = jsonData
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println("Error removing items from history: \(error)")
                completion(success: false)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                println(response)
                completion(success: false)
                return
            }
            
            var jsonSerializationError: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonSerializationError) as! [String: AnyObject]
            
            if let jsonSerializationError = jsonSerializationError {
                println(jsonSerializationError)
                completion(success: false)
            }
            else {
                completion(success: true)
            }
        }).resume()
    }
}
