//
//  People.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Public
    
    /**
     Returns a single person's details.
     */
    public func getPersonDetails<T: CustomStringConvertible>(personID id: T, extended: extendedType = .Min, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("people/\(id)?extended=\(extended.rawValue)", authorization: false, HTTPMethod: "GET") else {
            completion(dictionary: nil, error: TraktKitNoDataError)
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Returns all movies where this person is in the `cast` or `crew`. Each `cast` object will have a `character` and a standard `movie` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `movie` object.
     */
    public func getMovieCredits<T: CustomStringConvertible>(movieID id: T, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        return getCredits(type: WatchedType.Movies, id: id, completion: completion)
    }
    
    /**
     Returns all shows where this person is in the `cast` or `crew`. Each `cast` object will have a `character` and a standard `show` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `show` object.
     */
    public func getShowCredits<T: CustomStringConvertible>(showID id: T, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        return getCredits(type: WatchedType.Shows, id: id, completion: completion)
    }
    
    // MARK: - Private
    
    private func getCredits<T: CustomStringConvertible>(type type: WatchedType, id: T, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("people/\(id)/\(type)", authorization: false, HTTPMethod: "GET") else {
            completion(dictionary: nil, error: TraktKitNoDataError)
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
}
