//
//  Television.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /// The most popular shows calculated by rating percentage and number of ratings
    ///
    /// :param: page Skip to more results
    /// :param: limit Number of items per page
    ///
    /// :returns: Returns popular shows on Trakt.tv
    public func popularShows(#page: Int, limit: Int, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/popular?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println(error)
                completion(objects: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
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
    
    public func trendingShows(#page: Int, limit: Int, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/trending?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println(error)
                completion(objects: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
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
    
    public func getShowSummary(traktID: NSNumber, extended: extendedType = .Min, completion: dictionaryCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/\(traktID)?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error != nil {
                println(error)
                completion(dictionary: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
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
    
    /// Grabs the comments for a Show
    ///
    /// :param: traktID ID of the Show
    ///
    /// :returns: Returns all top level comments for a show. Most recent comments returned first.
    public func getShowComments(traktID: NSNumber, completion: ((comments: [[String: AnyObject]]?) -> Void)) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/comments"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var error: NSError?
            let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! [[String: AnyObject]]
            
            if let error = error {
                println(error)
                
                completion(comments: nil)
            }
            else {
                completion(comments: results)
            }
            
        }).resume()
    }
    
    /// Grabs the ratings for a Show
    ///
    /// :param: traktID ID of the Show
    ///
    /// :returns: Returns rating (between 0 and 10) and distribution for a show.
    public func getShowRatings(traktID: NSNumber, completion: ((ratings: [[String: AnyObject]]?) -> Void)) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/ratings"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var error: NSError?
            let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! [[String: AnyObject]]
            
            if let error = error {
                println(error)
                completion(ratings: nil)
            }
            else {
                completion(ratings: results)
            }
        }).resume()
    }
    
    // MARK: - Seasons
    
    public func getSeasons(showID: NSNumber, extended: extendedType = .Min, completion: (seasons: Array<Dictionary<String, AnyObject>>!) -> Void) {
        let urlString = "https://api-v2launch.trakt.tv/shows/\(showID)/seasons?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            var error: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! [[String: AnyObject]]!
            
            if let error = error {
                println(error)
                completion(seasons: nil)
            }
            else {
                completion(seasons: array)
            }
        }).resume()
    }
    
    public func getEpisodesForSeason(showID: NSNumber, seasonNumber: NSNumber, extended: extendedType = .Min, completion: (episodes: Array<Dictionary<String, AnyObject>>!) -> Void) {
        let urlString = "https://api-v2launch.trakt.tv/shows/\(showID)/seasons/\(seasonNumber)?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
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
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [[String: AnyObject]]
            
            if let error = error {
                println(error)
                completion(episodes: nil)
            }
            else {
                completion(episodes: array)
            }
        }).resume()
    }
    
    // MARK: - Episodes
    
    public func getEpisodeComments(traktID: NSNumber, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: arrayCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/comments"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                completion(objects: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var jsonSerializationError: NSError?
            let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonSerializationError) as? [[String: AnyObject]]
            
            if let jsonSerializationError = jsonSerializationError {
                println(jsonSerializationError)
                completion(objects: nil, error: jsonSerializationError)
            }
            else {
                completion(objects: results, error: nil)
            }
        }).resume()
    }
    
    public func getEpisodeRatings(traktID: NSNumber, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: dictionaryCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/ratings"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                completion(dictionary: nil, error: error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                println(response)
                return
            }
            
            var jsonSerializationError: NSError?
            let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonSerializationError) as? [String: AnyObject]
            
            if let jsonSerializationError = jsonSerializationError {
                println(jsonSerializationError)
                completion(dictionary: nil, error: jsonSerializationError)
            }
            else {
                completion(dictionary: results, error: nil)
            }
        }).resume()
    }
}