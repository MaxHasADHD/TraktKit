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
    
    public func popularMovies(page page: Int, limit: Int, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/movies/popular?page=\(page)&limit=\(limit)&extended=full,images"
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
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success else {
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
        }.resume()
    }
    
    public func trendingMovies(page page: Int, limit: Int, completion: arrayCompletionHandler) -> NSURLSessionDataTask {
        let urlString = "https://api-v2launch.trakt.tv/movies/trending?page=\(page)&limit=\(limit)&extended=full,images"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success else {
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
        }
        
        dataTask.resume()
        
        return dataTask
    }
    
    // MARK: - Updates
    
    public func updates(mediaType: watchedType, page: Int, limit: Int, startDate: String, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/\(mediaType.rawValue)/updates/\(startDate)?page=\(page)&limit=\(limit)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success else {
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
        }.resume()
    }
    
    // MARK: - Show summary
    
    public func getMovieSummary(movieID: NSNumber, extended: extendedType = .Min, completion: dictionaryCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/movies/\(movieID)?extended=\(extended.rawValue)"
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
            
            guard (response as! NSHTTPURLResponse).statusCode == statusCodes.success else {
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
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(dictionary: nil, error: jsonSerializationError)
            }
            catch {
                
            }
        }.resume()
    }
}