
//
//  Television.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Seasons
    
    public func getSeasons(showID: NSNumber, extended: extendedType = .Min, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/shows/\(showID)/seasons?extended=\(extended.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print(response)
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
                    print(jsonSerializationError)
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
        }.resume()
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
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print(response)
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
                    print(jsonSerializationError)
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
        }.resume()
    }
    
    // MARK: - Episodes
    
    public func getEpisodeComments(traktID: NSNumber, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: arrayCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/shows/\(traktID)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/comments"
        guard let URL = NSURL(string: URLString) else {
            completion(objects: nil, error: TraktKitNoDataError)
            return
        }
        let request = mutableRequestForURL(URL, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print(error)
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print(response)
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
                if let results = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: results, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                completion(objects: nil, error: jsonSerializationError)
            }
        }.resume()
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
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                #if DEBUG
                    print(response)
                #endif
                    
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        completion(dictionary: nil, error: self.createTraktErrorWithStatusCode(HTTPResponse.statusCode))
                    }
                    else {
                        completion(dictionary: nil, error: nil)
                    }
                return
            }
            
            // Check data
            guard let data = data else {
                completion(dictionary: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let results = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: results, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                print(jsonSerializationError)
                completion(dictionary: nil, error: jsonSerializationError)
            }
        }.resume()
    }
}