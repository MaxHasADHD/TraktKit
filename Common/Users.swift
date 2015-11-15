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
    
    public func getSettings(completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("users/settings", authorization: true, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    public func hiddenItems(section: SectionType, type: HiddenItemsType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("users/hidden/\(section.rawValue)?type=\(type.rawValue)", authorization: false, HTTPMethod: "GET") else { return nil }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    public func getStats(username: String, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("users/\(username)/stats", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    public typealias watchingCompletionHandler = (watching: Bool, dictionary: [String: AnyObject]?, error: NSError?) -> Void
    public func getWatching(username: String = "me", completion: watchingCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("users/\(username)/watching", authorization: true, HTTPMethod: "GET") else { return nil }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
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
        }
        dataTask.resume()
        
        return dataTask
    }
}