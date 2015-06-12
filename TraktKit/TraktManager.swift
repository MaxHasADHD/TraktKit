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
}

private let _SingletonASharedInstance = TraktManager()

public class TraktManager {
    
    // MARK: Internal
    let clientID = "XXXXX"
    let clientSecret = "YYYYY"
    let callbackURL = "ZZZZZ"
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // MARK: Public
    public var isSignedIn: Bool {
        get {
            return accessToken != nil
        }
    }
    public let oauthURL: NSURL?
    public var accessToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String
        }
        set {
            // Save somewhere secure
            println("Saving new access token \(newValue)")
            if newValue == nil {
                // Remove from user defaults
                NSUserDefaults.standardUserDefaults().removeObjectForKey("accessToken")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "accessToken")
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
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
            
            if (response as! NSHTTPURLResponse).statusCode != 201 {
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
            
            if (response as! NSHTTPURLResponse).statusCode != 201 {
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
    public func search(query: String, type: searchType, completion: ((results: Array<Dictionary<String, AnyObject>>!) -> Void)) {
        let urlString = "https://api-v2launch.trakt.tv/search?query=\(query)&type=\(type.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                println(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var error: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Array<Dictionary<String, AnyObject>>
            
            if let error = error {
                println(error)
                completion(results: nil)
            }
            else {
                completion(results: array)
            }
        }).resume()
    }
    
    // MARK: - Ratings
    
    public func getRatings(type: watchedType, id: NSNumber, extended: extendedType = .Min, completion: (summary: Dictionary<String, AnyObject>!) -> ()) {
        let urlString = "https://api-v2launch.trakt.tv/movies/\(id)/ratings"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var error: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Dictionary<String, AnyObject>
            
            if let error = error {
                println(error)
                
                completion(summary: nil)
            }
            else {
                completion(summary: dictionary)
            }
        }).resume()
    }

    // MARK: - Sync
    
    public func lastActivities(completion: ((results: Dictionary<String, AnyObject>!) -> Void)) {
        let urlString = "https://api-v2launch.trakt.tv/sync/last_activities"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                println("ERROR!: \(error)")
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var error: NSError?
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Dictionary<String, AnyObject>!
            
            if let error = error {
                println(error)
                completion(results: nil)
            }
            else {
                completion(results: dictionary)
            }
        }).resume()
    }
    
    public func getWatched(type: watchedType, completion: ((shows: Array<Dictionary<String, AnyObject>>!) -> Void)) {
        let urlString = "https://api-v2launch.trakt.tv/sync/watched/\(type.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println("ERROR!: \(error)")
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var error: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Array<Dictionary<String, AnyObject>>!
            
            if let error = error {
                println(error)
                completion(shows: nil)
            }
            else {
                completion(shows: array)
            }
        }).resume()
    }
    
    public func addToHistory(#movies: Array<String>, shows: Array<String>, episodes: Array<String>, completion: ((success: Bool) -> Void)) {
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
            if (response as! NSHTTPURLResponse).statusCode != 201 {
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
    
    public func removeFromHistory(#movies: Array<String>, shows: Array<String>, episodes: Array<String>, completion: ((success: Bool) -> Void)) {
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
                println("ERROR!: \(error)")
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
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
}
