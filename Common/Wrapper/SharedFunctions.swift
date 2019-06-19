//
//  SharedFunctions.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/27/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

internal extension TraktManager {
    
    // MARK: - Trending
    
    func getTrending<T>(_ type: WatchedType, pagination: Pagination?, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        if let filters = filters {
            for (key, value) in (filters.map { $0.value() }) {
                query[key] = value
            }
        }

        guard var request = mutableRequest(forPath: "\(type)/trending",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Popular
    
    func getPopular<T>(_ type: WatchedType, pagination: Pagination?, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        if let filters = filters {
            for (key, value) in (filters.map { $0.value() }) {
                query[key] = value
            }
        }
        
        guard var request = mutableRequest(forPath: "\(type)/popular",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Played
    
    func getPlayed<T>(_ type: WatchedType, period: Period = .Weekly, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard var request = mutableRequest(forPath: "\(type)/played/\(period.rawValue)",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Watched
    
    func getWatched<T>(_ type: WatchedType, period: Period = .Weekly, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard var request = mutableRequest(forPath: "\(type)/watched/\(period.rawValue)",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Collected
    
    func getCollected<T>(_ type: WatchedType, period: Period = .Weekly, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard var request = mutableRequest(forPath: "\(type)/collected/\(period.rawValue)",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Anticipated
    
    func getAnticipated<T>(_ type: WatchedType, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard var request = mutableRequest(forPath: "\(type)/anticipated",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Updates
    
    func getUpdated(_ type: WatchedType, startDate: Date?, pagination: Pagination?, extended: [ExtendedType], completion: @escaping UpdateCompletionHandler) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }
        
        var path = "\(type)/updates/"
        if let startDateString = startDate?.dateString(withFormat: "yyyy-MM-dd") {
            path.append(startDateString)
        }
        
        guard var request = mutableRequest(forPath: path,
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Summary
    
    func getSummary<T: CustomStringConvertible, U: Decodable>(_ type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<U>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Aliases
    
    func getAliases<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping AliasCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/aliases",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Translations
    
    func getTranslations<T: CustomStringConvertible, U>(_ type: WatchedType, id: T, language: String?, completion: @escaping ((_ result: ObjectsResultType<U>) -> Void)) -> URLSessionDataTaskProtocol? {
        
        var path = "\(type)/\(id)/translations"
        if let language = language {
            path += "/\(language)"
        }
        
        guard let request = mutableRequest(forPath: path,
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Comments
    
    func getComments<T: CustomStringConvertible>(_ type: WatchedType, id: T, pagination: Pagination?, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = [:]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = mutableRequest(forPath: "\(type)/\(id)/comments",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - People
    
    func getPeople<T: CustomStringConvertible>(_ type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/people",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Ratings
    
    func getRatings<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/ratings",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Related
    
    func getRelated<T: CustomStringConvertible, U>(_ type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping ((_ result: ObjectsResultType<U>) -> Void)) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/related",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Stats
    
    func getStatistics<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping statsCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/stats",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Watching
    
    func getUsersWatching<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping ObjectsCompletionHandler<User>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/watching",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
}
