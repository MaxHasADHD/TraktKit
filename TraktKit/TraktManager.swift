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

public class TraktManager {
    
    // MARK: Internal
    let clientID = "XXXXX"
    let clientSecret = "YYYYY"
    let callbackURL = "ZZZZZ"
    lazy var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // MARK: Public
    public static let sharedManager = TraktManager()
    
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
                let succeeded = MLKeychain.setString(newValue!, forKey: "accessToken")
                print("Saved access token: \(succeeded)")
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
    
    // MARK: Authentication
    
    public func getTokenFromAuthorizationCode(code: String) {
        let urlString = "https://trakt.tv/oauth/token"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "POST")
        let httpBodyString = "{\"code\": \"\(code)\", \"client_id\": \"\(clientID)\", \"client_secret\": \"\(clientSecret)\", \"redirect_uri\": \"\(callbackURL)\", \"grant_type\": \"authorization_code\" }"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    // TODO: Store the expire date
//                    let timeInterval = dictionary["expires_in"] as! NSNumber
//                    let expiresDate = NSDate(timeIntervalSinceNow: timeInterval.doubleValue)
                    
                    self.accessToken = dictionary["access_token"] as? String
                    print(self.accessToken)
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName("signedInToTrakt", object: nil)
                    })
                }
            }
            catch {
                
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
            if error != nil {
                print(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.successNewResourceCreated.rawValue {
                print(response)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    if let error = error {
                        print(error)
//                        completion(results: nil)
                    }
                    else {
//                        completion(results: array)
                    }
                }
            }
            catch {
                
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
            if error != nil {
                print(error)
                completion(objects: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                print(response)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: array, error: nil)
                }
            }
            catch let caught as NSError {
                completion(objects: nil, error: caught)
            }
            catch {
                print("Something went wrong!")
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
            if error != nil {
                print(error)
                completion(dictionary: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                print(response)
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: dictionary, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                print(jsonSerializationError)
                completion(dictionary: nil, error: jsonSerializationError)
            }
            catch {
                print("Something went wrong!")
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
            if error != nil {
                print("Error getting users last activities: \(error)")
                completion(dictionary: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                print(response)
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                   completion(dictionary: dictionary, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                print(jsonSerializationError)
                completion(dictionary: nil, error: jsonSerializationError)
            }
            catch {
                print("Something went wrong!")
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
            if error != nil {
                print("Error getting users watched shows: \(error)")
                completion(objects: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != statusCodes.success.rawValue {
                print(response)
                completion(objects: [], error: nil)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: array, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                print(jsonSerializationError)
                completion(objects: nil, error: jsonSerializationError)
            }
            catch {
                print("Something went wrong!")
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
                    print(error)
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
                    print(error)
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
                completion(success: false)
            }
        }.resume()
    }
}
