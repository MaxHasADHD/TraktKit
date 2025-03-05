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

    public func perform(retryLimit: Int = 3) async throws -> T {
        let request = try createRequest()
        return try await traktManager.perform(request: request, retryLimit: retryLimit)
    }

    private func createRequest() throws -> URLRequest {
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

// MARK: - No data response

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

    public func perform(retryLimit: Int = 3) async throws {
        let request = try traktManager.mutableRequest(
            forPath: path,
            withQuery: [:],
            isAuthorized: requiresAuthentication,
            withHTTPMethod: method
        )
        let _ = try await traktManager.fetchData(request: request, retryLimit: retryLimit)
    }
}

// MARK: - Pagination

public protocol PagedObjectProtocol {
    static var objectType: Decodable.Type { get }
    static func createPagedObject(with object: Decodable, currentPage: Int, pageCount: Int) -> Self
}

public struct PagedObject<TraktModel: TraktObject>: PagedObjectProtocol, TraktObject {
    public let object: TraktModel
    public let currentPage: Int
    public let pageCount: Int

    public static var objectType: any Decodable.Type {
        TraktModel.self
    }

    public static func createPagedObject(with object: Decodable, currentPage: Int, pageCount: Int) -> Self {
        return PagedObject(object: object as! TraktModel, currentPage: currentPage, pageCount: pageCount)
    }
}

extension Route where T: PagedObjectProtocol {

    /// Fetches all pages for a paginated endpoint, and returns the data in a Set.
    func fetchAllPages<Element>() async throws -> Set<Element> where T.Type == PagedObject<[Element]>.Type {
        // Fetch first page
        let firstPage = try await self.page(1).perform()
        var resultSet = Set<Element>(firstPage.object)

        // Return early if there's only one page
        guard firstPage.pageCount > 1 else { return resultSet }
        resultSet = await withTaskGroup(of: [Element].self, returning: Set<Element>.self) { group in
            let maxConcurrentRequests = min(firstPage.pageCount - 1, 10)
            let pages = 2...firstPage.pageCount

            let indexStream = AsyncStream<Int> { continuation in
                for i in pages {
                    continuation.yield(i)
                }
                continuation.finish()
            }
            var indexIterator = indexStream.makeAsyncIterator()
            var results = resultSet

            // Start with the initial batch of tasks
            for _ in 0..<maxConcurrentRequests {
                if let index = await indexIterator.next() {
                    group.addTask {
                        (try? await self.page(index).perform())?.object ?? []
                    }
                }
            }

            // Continue adding new tasks as others finish
            while let result = await group.next() {
                results.formUnion(result)  // Merge the `[Int]` result into `Set<Int>
                if let index = await indexIterator.next() {
                    group.addTask {
                        (try? await self.page(index).perform())?.object ?? []
                    }
                }
            }

            return results
        }

        return resultSet
    }

    /// Stream paged results one at a time
    func pagedResults<Element>() -> AsyncThrowingStream<[Element], Error> where T.Type == PagedObject<[Element]>.Type {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    // Fetch first page
                    let firstPage = try await self.page(1).perform()
                    continuation.yield(firstPage.object)

                    guard firstPage.pageCount > 1 else {
                        continuation.finish()
                        return
                    }

                    // Use a semaphore to limit concurrency
                    let semaphore = AsyncSemaphore(value: 10)
                    let pages = 2...firstPage.pageCount

                    try await withThrowingTaskGroup(of: (Int, [Element]).self) { group in
                        for pageIndex in pages {
                            // Acquire permit before starting new task
                            try await semaphore.acquire()

                            group.addTask {
                                do {
                                    let pageResult = try await self.page(pageIndex).perform().object
                                    await semaphore.release()
                                    return (pageIndex, pageResult)
                                } catch {
                                    await semaphore.release()
                                    throw error
                                }
                            }
                        }

                        // Process results in order
                        var nextPage = 2
                        var buffer = [Int: [Element]]()

                        while let result = try await group.next() {
                            let (pageIndex, items) = result

                            if pageIndex == nextPage {
                                // We got the next page we need
                                continuation.yield(items)
                                nextPage += 1

                                // Check if we have any buffered pages that can be yielded now
                                while let bufferedItems = buffer[nextPage] {
                                    continuation.yield(bufferedItems)
                                    buffer[nextPage] = nil
                                    nextPage += 1
                                }
                            } else {
                                // Buffer out-of-order results
                                buffer[pageIndex] = items
                            }
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

// A simple AsyncSemaphore implementation
actor AsyncSemaphore {
    private var value: Int
    private var waiters: [CheckedContinuation<Void, Error>] = []

    init(value: Int) {
        self.value = value
    }

    func acquire() async throws {
        if value > 0 {
            value -= 1
            return
        }

        try await withCheckedThrowingContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func release() {
        if let waiter = waiters.first {
            waiters.removeFirst()
            waiter.resume()
        } else {
            value += 1
        }
    }
}
