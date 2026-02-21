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
    @available(*, deprecated, message: "Use genres.list(type:).perform() with async/await instead. See MIGRATION_GUIDE.md for examples.")
    @discardableResult
    public func listGenres(type: WatchedType, completion: @escaping ObjectCompletionHandler<[Genres]>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "genres/\(type)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else {
                                                completion(.error(error: nil))
                                                return nil
                                           }
        return performRequest(request: request,
                              completion: completion)
    }
}
