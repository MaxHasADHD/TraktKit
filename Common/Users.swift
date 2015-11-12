//
//  Users.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/18/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

public enum SectionType: String {
    case Calendar = "calendar"
    case ProgressWatched = "progress_watched"
    case ProgressCollected = "progress_collected"
    case Recommendations = "recommendations"
}

public enum HiddenItemsType: String {
    case Movie = "movie"
    case Show = "show"
    case Season = "Season"
}

extension TraktManager {
    
    public func getSettings(completion: dictionaryCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/users/settings"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
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
                if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: dict, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(dictionary: nil, error: jsonSerializationError)
            }
        }.resume()
    }
    
    public func hiddenItems(section: SectionType, type: HiddenItemsType, completion: arrayCompletionHandler) {
        let urlString = "https://api-v2launch.trakt.tv/users/hidden/\(section.rawValue)?type=\(type.rawValue)"
        let url = NSURL(string: urlString)
        let request = mutableRequestForURL(url, authorization: false, HTTPMethod: "GET")
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
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
                    completion(objects: nil, error: nil)
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
                completion(objects: nil, error: jsonSerializationError)
            }
            
        }.resume()
    }
    
    public func getStats(username: String, completion: dictionaryCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/users/\(username)/stats"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: false, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
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
                if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: dict, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(dictionary: nil, error: jsonSerializationError)
            }
        }.resume()
    }
    
    public typealias watchingCompletionHandler = (watching: Bool, dictionary: [String: AnyObject]?, error: NSError?) -> Void
    public func getWatching(username: String = "me", completion: watchingCompletionHandler) {
        let URLString = "https://api-v2launch.trakt.tv/users/\(username)/watching"
        let URL = NSURL(string: URLString)
        let request = mutableRequestForURL(URL!, authorization: true, HTTPMethod: "GET")
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(watching: false, dictionary: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success ||
                    HTTPResponse.statusCode == statusCodes.successNoContentToReturn else {
                        #if DEBUG
                            print(response)
                        #endif
                        
                        if let HTTPResponse = response as? NSHTTPURLResponse {
                            completion(watching: false, dictionary: nil, error: self.createTraktErrorWithStatusCode(HTTPResponse.statusCode))
                        }
                        else {
                            completion(watching: false, dictionary: nil, error: TraktKitNoDataError)
                        }
                        return
            }
            
            if HTTPResponse.statusCode == statusCodes.successNoContentToReturn {
                completion(watching: false, dictionary: nil, error: nil)
                return
            }
            
            // Check data
            guard let data = data else {
                completion(watching: false, dictionary: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(watching: true, dictionary: dict, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(watching: false, dictionary: nil, error: jsonSerializationError)
            }
        }.resume()
    }
}