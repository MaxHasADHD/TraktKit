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
    
    public func popularMovies(page page: Int, limit: Int, completion: ((movies: Array<Dictionary<String, AnyObject>>!) -> Void)) {
        let urlString = "https://api-v2launch.trakt.tv/movies/popular?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(movies: array)
                }
            }
            catch let error as NSError {
                print(error)
                completion(movies: nil)
            }
            catch {
                
            }
        }?.resume()
    }
    
    public func trendingMovies(page page: Int, limit: Int, completion: ((movies: Array<Dictionary<String, AnyObject>>!) -> Void)) {
        let urlString = "https://api-v2launch.trakt.tv/movies/trending?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(movies: array)
                }
            }
            catch let error as NSError {
                print(error)
                completion(movies: nil)
            }
            catch {
                
            }
        }?.resume()
    }
    
    // MARK: - Updates
    
    public func updates(mediaType: watchedType, page: Int, limit: Int, startDate: String, completion: (media: Array<Dictionary<String, AnyObject>>!) -> Void) {
        let urlString = "https://api-v2launch.trakt.tv/\(mediaType.rawValue)/updates/\(startDate)?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(media: array)
                }
            }
            catch let error as NSError {
                print(error)
                completion(media: nil)
            }
            catch {
                
            }
        }?.resume()
    }
    
    // MARK: - Show summary
    
    public func getMovieSummary(movieID: NSNumber, extended: extendedType = .Min, completion: (summary: Dictionary<String, AnyObject>!) -> ()) {
        let urlString = "https://api-v2launch.trakt.tv/movies/\(movieID)?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            if (response as! NSHTTPURLResponse).statusCode != 200 {
                print(response)
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(summary: dictionary)
                }
            }
            catch let error as NSError {
                print(error)
                completion(summary: nil)
            }
            catch {
                
            }
        }?.resume()
    }
}