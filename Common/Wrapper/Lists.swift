//
//  Lists.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/29/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {

    /**
     Returns all lists with the most likes and comments over the last 7 days.

     📄 Pagination
     */
    @discardableResult
    public func getTrendingLists(completion: @escaping ObjectsCompletionHandler<TraktTrendingList>) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "lists/trending",
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

    /**
     Returns the most popular lists. Popularity is calculated using total number of likes and comments.

     📄 Pagination
     */
    @discardableResult
    public func getPopularLists(completion: @escaping ObjectsCompletionHandler<TraktTrendingList>) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "lists/popular",
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
