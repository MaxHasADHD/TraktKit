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
    @discardableResult
    public func getRecommendedMovies(completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        return self.getRecommendations(type: .Movies, completion: completion)
    }
    
    /**
     Hide a movie from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func hideRecommendedMovie<T: CustomStringConvertible>(movieID id: T, completion: SuccessCompletionHandler) -> URLSessionDataTask? {
        return hideRecommendation(type: .Movies, id: id, completion: completion)
    }
    
    /**
     Personalized show recommendations for a user. Results returned with the top recommendation first.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func getRecommendedShows(completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        return self.getRecommendations(type: .Shows, completion: completion)
    }
    
    /**
     Hide a show from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func hideRecommendedShow<T: CustomStringConvertible>(showID id: T, completion: SuccessCompletionHandler) -> URLSessionDataTask? {
        return hideRecommendation(type: .Shows, id: id, completion: completion)
    }
    
    // MARK: - Private
    @discardableResult
    private func getRecommendations(type: WatchedType, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL(path: "recommendations/\(type)", authorization: true, HTTPMethod: .GET) else {
            completion(result: .Error(error: nil))
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    @discardableResult
    private func hideRecommendation<T: CustomStringConvertible>(type: WatchedType, id: T, completion: SuccessCompletionHandler) -> URLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL(path: "recommendations/\(type)/\(id)", authorization: true, HTTPMethod: .DELETE) else {
            completion(result: .Fail)
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNoContentToReturn, completion: completion)
    }
    
}
