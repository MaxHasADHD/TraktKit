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
    @discardableResult
    public func listGenres(type: WatchedType, completion: @escaping ObjectsCompletionHandler<Genres>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "genres/\(type)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else {
                                                completion(.error(error: nil))
                                                return nil
                                           }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }
}
