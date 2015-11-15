//
//  Recommendations.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Public
    
    /**
     Personalized movie recommendations for a user. Results returned with the top recommendation first.
     
     🔒 OAuth: Required
     */
    public func getRecommendedMovies(completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        return self.getRecommendations(.Movies, completion: completion)
    }
    
    /**
     Hide a movie from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    public func hideRecommendedMovie(traktID traktID: NSNumber, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        return hideRecommendation(type: .Movies, traktID: traktID, completion: completion)
    }
    
    /**
     Personalized show recommendations for a user. Results returned with the top recommendation first.
     
     🔒 OAuth: Required
     */
    public func getRecommendedShows(completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        return self.getRecommendations(.Shows, completion: completion)
    }
    
    /**
     Hide a show from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    public func hideRecommendedShow(traktID traktID: NSNumber, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        return hideRecommendation(type: .Shows, traktID: traktID, completion: completion)
    }
    
    // MARK: - Private
    
    private func getRecommendations(type: WatchedType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("recommendations/\(type)", authorization: true, HTTPMethod: "GET") else {
            completion(objects: nil, error: TraktKitNoDataError)
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
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
        }
        
        dataTask.resume()
        return dataTask
    }
    
    private func hideRecommendation(type type: WatchedType, traktID: NSNumber, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("recommendations/\(type)/\(traktID)", authorization: true, HTTPMethod: "DELETE") else {
            completion(success: false)
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNoContentToReturn else {
                    #if DEBUG
                        print(response)
                    #endif
                    
                    completion(success: false)
                    
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
}
