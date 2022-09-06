//
//  Route.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public class Route<T: Codable> {
    public let path: String
    public let method: Method
    private let resultType: T.Type
    public let traktManager: TraktManager

    private var extended: [ExtendedType] = []
    private var _page: Int?
    private var _limit: Int?
    
    private var filters = [FilterType]()

    private var request: URLRequest {
        var query: [String: String] = [:]

        if !extended.isEmpty {
            query["extended"] = extended.queryString()
        }

        // pagination
        if let page = _page {
            query["page"] = page.description
        }

        if let limit = _limit {
            query["limit"] = limit.description
        }
        
        // Filters
        if filters.isEmpty == false {
            for (key, value) in (filters.map { $0.value() }) {
                query[key] = value
            }
        }

        return traktManager.mutableRequest(forPath: path,
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: method)!
    }

    public init(path: String, method: Method, traktManager: TraktManager, resultType: T.Type = T.self) {
        self.path = path
        self.method = method
        self.resultType = resultType
        self.traktManager = traktManager
    }

    public func extend(_ extended: ExtendedType...) -> Self {
        self.extended = extended
        return self
    }
    
    // MARK: - Pagination

    public func page(_ page: Int?) -> Self {
        self._page = page
        return self
    }

    public func limit(_ limit: Int?) -> Self {
        self._limit = limit
        return self
    }
    
    // MARK: - Filters
    
    public func filter(_ filter: TraktManager.Filter) -> Self {
        filters.append(filter)
        return self
    }
    
    // MARK: - Perform

    public func perform() async throws -> T {
        try await traktManager.perform(request: request)
    }
}
