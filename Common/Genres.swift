//
//  Genres.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/15/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Get a list of all genres, including names and slugs.
     */
    public func listGenres(type type: WatchedType, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("genres/\(type)", authorization: false, HTTPMethod: .GET) else {
            completion(result: .Error(error: nil))
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
