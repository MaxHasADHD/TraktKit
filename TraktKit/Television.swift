
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
    public func popularShows(page page: Int, limit: Int, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/popular?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(objects: nil, error: nil)
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
                
            }
        }?.resume()
    }
    
    public func trendingShows(page page: Int, limit: Int, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/trending?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(objects: nil, error: nil)
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
                
            }
        }?.resume()
    }
    
    public func getShowSummary(traktID: NSNumber, extended: extendedType = .Min, completion: dictionaryCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/\(traktID)?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(dictionary: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(dictionary: nil, error: nil)
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
                
            }
        }?.resume()
    }
    
    /// Grabs the comments for a Show
    ///
    /// :param: traktID ID of the Show
    ///
    /// :returns: Returns all top level comments for a show. Most recent comments returned first.
    public func getShowComments(traktID: NSNumber, completion: arrayCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/comments"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(objects: nil, error: nil)
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
                
            }
        }?.resume()
    }
    
    /// Grabs the ratings for a Show
    ///
    /// :param: traktID ID of the Show
    ///
    /// :returns: Returns rating (between 0 and 10) and distribution for a show.
    public func getShowRatings(traktID: NSNumber, completion: arrayCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/ratings"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(objects: nil, error: nil)
                return
            }
            
            do {
                if let results = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: results, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                print(jsonSerializationError)
                completion(objects: nil, error: jsonSerializationError)
            }
            catch {
                
            }
        }?.resume()
    }
    
    // MARK: - Seasons
    
    public func getSeasons(showID: NSNumber, extended: extendedType = .Min, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/\(showID)/seasons?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(objects: nil, error: nil)
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
                
            }
        }?.resume()
    }
    
    public func getEpisodesForSeason(showID: NSNumber, seasonNumber: NSNumber, extended: extendedType = .Min, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/\(showID)/seasons/\(seasonNumber)?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(objects: nil, error: nil)
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
                
            }
        }?.resume()
    }
    
    // MARK: - Episodes
    
    public func getEpisodeComments(traktID: NSNumber, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: arrayCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/comments"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(objects: nil, error: nil)
                return
            }
            
            do {
                if let results = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: results, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                print(jsonSerializationError)
                completion(objects: nil, error: jsonSerializationError)
            }
            catch {
                
            }
        }?.resume()
    }
    
    public func getEpisodeRatings(traktID: NSNumber, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: dictionaryCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/ratings"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(dictionary: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success.rawValue else {
                #if DEBUG
                    print(response)
                #endif
                completion(dictionary: nil, error: nil)
                return
            }
            
            do {
                if let results = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: results, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                print(jsonSerializationError)
                completion(dictionary: nil, error: jsonSerializationError)
            }
            catch {
                
            }
        }?.resume()
    }
}