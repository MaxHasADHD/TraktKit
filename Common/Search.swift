//
//  Search.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/26/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    /**
     Perform a text query that searches titles, descriptions, translated titles, aliases, and people. Items searched include movies, shows, episodes, people, and lists. Results are ordered by the most relevant score.
     
     You can optionally limit the `type` of results to return. Send a comma separated string to get results for multiple types. You can optionally filter the `year` for `movie` and `show` results.
     
     Status Code: 200
     
     */
    public func search(query: String, types: [SearchType], completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        
        let typesString = types.map { $0.rawValue }.joinWithSeparator(",") // Search with multiple types
        
        guard let request = mutableRequestForURL("search?query=\(query)&type=\(typesString)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /** 
     Lookup an item by using a Trakt.tv ID or other external ID. This is helpful to get an items info including the Trakt.tv ID.
     
     Status Code: 200
     */
    public func lookup<T: CustomStringConvertible>(id: T, idType: LookupType, completion: ArrayCompletionHandler) -> NSURLSessionTask? {
        guard let request = mutableRequestForURL("search?id_type=\(idType.rawValue)&id=\(id)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
