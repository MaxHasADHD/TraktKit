//
//  Route.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Route<T: TraktObject>: Sendable {

    // MARK: - Properties

    private let resultType: T.Type
    private let traktManager: TraktManager

    internal var path: String
    internal let method: Method
    internal let requiresAuthentication: Bool
    internal var queryItems: [String: String]

    private var extended = [ExtendedType]()
    private var page: Int?
    private var limit: Int?

    private var filters = [FilterType]()
    private var searchType: SearchType?
    private var searchQuery: String?

    private var body: (any EncodableTraktObject)?

    // MARK: - Lifecycle

    public init(path: String, queryItems: [String: String] = [:], body: (any TraktObject)? = nil, method: Method, requiresAuthentication: Bool = false, resultType: T.Type = T.self, traktManager: TraktManager) {
        self.path = path
        self.queryItems = queryItems
        self.body = body
        self.method = method
        self.requiresAuthentication = requiresAuthentication
        self.resultType = resultType
        self.traktManager = traktManager
    }

    public init(paths: [CustomStringConvertible?], queryItems: [String: String] = [:], body: (any EncodableTraktObject)? = nil, method: Method, requiresAuthentication: Bool = false, resultType: T.Type = T.self, traktManager: TraktManager) {
        self.path = paths.compactMap { $0?.description }.joined(separator: "/")
        self.queryItems = queryItems
        self.body = body
        self.method = method
        self.requiresAuthentication = requiresAuthentication
        self.resultType = resultType
        self.traktManager = traktManager
    }

    // MARK: - Actions

    public func extend(_ extended: ExtendedType...) -> Self {
        var copy = self
        copy.extended = extended
        return copy
    }

    // MARK: - Pagination

    public func page(_ page: Int?) -> Self {
        var copy = self
        copy.page = page
        return copy
    }

    public func limit(_ limit: Int?) -> Self {
        var copy = self
        copy.limit = limit
        return copy
    }

    // MARK: - Filters

    public func filter(_ filter: TraktManager.Filter) -> Self {
        var copy = self
        copy.filters.append(filter)
        return copy
    }

    public func type(_ type: SearchType?) -> Self {
        var copy = self
        copy.searchType = type
        return copy
    }

    // MARK: - Search

    public func query(_ query: String?) -> Self {
        var copy = self
        copy.searchQuery = query
        return copy
    }

    // MARK: - Perform

    public func perform() async throws -> T {
        let request = try makeRequest(traktManager: traktManager)
        return try await traktManager.perform(request: request)
    }

    private func makeRequest(traktManager: TraktManager) throws -> URLRequest {
        var query: [String: String] = queryItems

        if !extended.isEmpty {
            query["extended"] = extended.queryString()
        }

        // pagination
        if let page {
            query["page"] = page.description
        }

        if let limit {
            query["limit"] = limit.description
        }

        // Search

        if let searchType {
            query["type"] = searchType.rawValue
        }

        if let searchQuery {
            query["query"] = searchQuery
        }

        // Filters
        if !filters.isEmpty {
            for (key, value) in (filters.map { $0.value() }) {
                query[key] = value
            }
        }

        return try traktManager.mutableRequest(
            forPath: path,
            withQuery: query,
            isAuthorized: requiresAuthentication,
            withHTTPMethod: method,
            body: body
        )
    }
}

public struct EmptyRoute: Sendable {
    internal var path: String
    internal let method: Method
    internal let requiresAuthentication: Bool
    private let traktManager: TraktManager

    // MARK: - Lifecycle

    public init(path: String, method: Method, requiresAuthentication: Bool = false, traktManager: TraktManager) {
        self.path = path
        self.method = method
        self.requiresAuthentication = requiresAuthentication
        self.traktManager = traktManager
    }

    public init(paths: [CustomStringConvertible?], method: Method, requiresAuthentication: Bool = false, traktManager: TraktManager) {
        self.path = paths.compactMap { $0?.description }.joined(separator: "/")
        self.method = method
        self.requiresAuthentication = requiresAuthentication
        self.traktManager = traktManager
    }

    // MARK: - Perform

    public func perform() async throws {
        let request = try traktManager.mutableRequest(
            forPath: path,
            withQuery: [:],
            isAuthorized: requiresAuthentication,
            withHTTPMethod: method
        )
        let _ = try await traktManager.fetchData(request: request)
    }
}

public protocol PagedObjectProtocol {
    static var objectType: Decodable.Type { get }
    static func createPagedObject(with object: Decodable, currentPage: Int, pageCount: Int) -> Self
}

public struct PagedObject<T: TraktObject>: PagedObjectProtocol, TraktObject {
    public let object: T
    public let currentPage: Int
    public let pageCount: Int

    public static var objectType: any Decodable.Type {
        T.self
    }

    public static func createPagedObject(with object: Decodable, currentPage: Int, pageCount: Int) -> Self {
        return PagedObject(object: object as! T, currentPage: currentPage, pageCount: pageCount)
    }
}
