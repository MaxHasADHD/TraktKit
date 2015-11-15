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
    public func getPersonDetails(TraktID ID: NSNumber, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("people/\(ID)", authorization: false, HTTPMethod: "GET") else {
            completion(dictionary: nil, error: TraktKitNoDataError)
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Returns all movies where this person is in the `cast` or `crew`. Each `cast` object will have a `character` and a standard `movie` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `movie` object.
     */
    public func getMovieCredits(TraktID ID: NSNumber, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        return getCredits(type: WatchedType.Movies, TraktID: ID, completion: completion)
    }
    
    /**
     Returns all shows where this person is in the `cast` or `crew`. Each `cast` object will have a `character` and a standard `show` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `show` object.
     */
    public func getShowCredits(TraktID ID: NSNumber, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        return getCredits(type: WatchedType.Shows, TraktID: ID, completion: completion)
    }
    
    // MARK: - Private
    
    private func getCredits(type type: WatchedType, TraktID ID: NSNumber, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("people/\(ID)/\(type)", authorization: false, HTTPMethod: "GET") else {
            completion(dictionary: nil, error: TraktKitNoDataError)
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
}
