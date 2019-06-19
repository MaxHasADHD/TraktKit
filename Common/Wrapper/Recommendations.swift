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
     Personalized movie recommendations for a user. Results returned with the top recommendation first. By default, `10` results are returned. You can send a limit to get up to `100` results per page.
     
     🔒 OAuth: Required
     ✨ Extended Info
     */
    @discardableResult
    public func getRecommendedMovies(completion: @escaping ObjectsCompletionHandler<TraktMovie>) -> URLSessionDataTaskProtocol? {
        return getRecommendations(.Movies, completion: completion)
    }
    
    /**
     Hide a movie from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func hideRecommendedMovie<T: CustomStringConvertible>(movieID id: T, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        return hideRecommendation(type: .Movies, id: id, completion: completion)
    }
    
    /**
     Personalized show recommendations for a user. Results returned with the top recommendation first.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func getRecommendedShows(completion: @escaping ObjectsCompletionHandler<TraktShow>) -> URLSessionDataTaskProtocol? {
        return getRecommendations(.Shows, completion: completion)
    }
    
    /**
     Hide a show from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func hideRecommendedShow<T: CustomStringConvertible>(showID id: T, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        return hideRecommendation(type: .Shows, id: id, completion: completion)
    }
    
    // MARK: - Private
    
    @discardableResult
    private func getRecommendations<T>(_ type: WatchedType, completion: @escaping ObjectsCompletionHandler<T>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "recommendations/\(type)",
            withQuery: [:],
            isAuthorized: true,
            withHTTPMethod: .GET) else {
                completion(.error(error: nil))
                return nil
        }
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    @discardableResult
    private func hideRecommendation<T: CustomStringConvertible>(type: WatchedType, id: T, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "recommendations/\(type)/\(id)",
            withQuery: [:],
            isAuthorized: true,
            withHTTPMethod: .DELETE) else {
                completion(.fail)
                return nil
        }
        return performRequest(request: request,
                              completion: completion)
    }
}

