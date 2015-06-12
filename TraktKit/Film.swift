//
//  Film.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Discovery
    
    public func popularMovies(#page: Int, limit: Int, completion: ((movies: Array<Dictionary<String, AnyObject>>!) -> Void)) {
        let urlString = "https://api-v2launch.trakt.tv/movies/popular?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            var error: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Array<Dictionary<String, AnyObject>>!
            
            if let error = error {
                println(error)
                completion(movies: nil)
            }
            else {
                completion(movies: array)
            }
        }).resume()
    }
    
    public func trendingMovies(#page: Int, limit: Int, completion: ((movies: Array<Dictionary<String, AnyObject>>!) -> Void)) {
        let urlString = "https://api-v2launch.trakt.tv/movies/trending?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            var error: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Array<Dictionary<String, AnyObject>>!
            
            if let error = error {
                println(error)
                completion(movies: nil)
            }
            else {
                completion(movies: array)
            }
        }).resume()
    }
    
    // MARK: - Updates
    
    public func updates(mediaType: watchedType, page: Int, limit: Int, startDate: String, completion: (media: Array<Dictionary<String, AnyObject>>!) -> Void) {
        let urlString = "https://api-v2launch.trakt.tv/\(mediaType.rawValue)/updates/\(startDate)?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            var error: NSError?
            let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Array<Dictionary<String, AnyObject>>!
            
            if let error = error {
                println(error)
                completion(media: nil)
            }
            else {
                completion(media: array)
            }
        }).resume()
    }
    
    // MARK: - Show summary
    
    public func getMovieSummary(movieID: NSNumber, extended: extendedType = .Min, completion: (summary: Dictionary<String, AnyObject>!) -> ()) {
        let urlString = "https://api-v2launch.trakt.tv/movies/\(movieID)?extended=\(extended.rawValue)"
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
}