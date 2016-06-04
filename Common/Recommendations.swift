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
    public func getRecommendedMovies(completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return self.getRecommendations(.Movies, completion: completion)
    }
    
    /**
     Hide a movie from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    public func hideRecommendedMovie<T: CustomStringConvertible>(movieID id: T, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        return hideRecommendation(type: .Movies, id: id, completion: completion)
    }
    
    /**
     Personalized show recommendations for a user. Results returned with the top recommendation first.
     
     🔒 OAuth: Required
     */
    public func getRecommendedShows(completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return self.getRecommendations(.Shows, completion: completion)
    }
    
    /**
     Hide a show from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    public func hideRecommendedShow<T: CustomStringConvertible>(showID id: T, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        return hideRecommendation(type: .Shows, id: id, completion: completion)
    }
    
    // MARK: - Private
    
    private func getRecommendations(type: WatchedType, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("recommendations/\(type)", authorization: true, HTTPMethod: .GET) else {
            completion(result: .Error(error: nil))
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    private func hideRecommendation<T: CustomStringConvertible>(type type: WatchedType, id: T, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("recommendations/\(type)/\(id)", authorization: true, HTTPMethod: .DELETE) else {
            completion(result: .Fail)
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNoContentToReturn, completion: completion)
    }
    
}
