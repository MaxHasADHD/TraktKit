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
    
    func getTrending<T: TraktObject>(_ type: WatchedType, pagination: Pagination?, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTask? {

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

        guard let request = try? mutableRequest(forPath: "\(type)/trending",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Popular
    
    func getPopular<T: TraktObject>(_ type: WatchedType, pagination: Pagination?, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTask? {

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
        
        guard let request = try? mutableRequest(forPath: "\(type)/popular",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Played
    
    func getPlayed<T: TraktObject>(_ type: WatchedType, period: Period = .weekly, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTask? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = try? mutableRequest(forPath: "\(type)/played/\(period.rawValue)",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Watched
    
    func getWatched<T: TraktObject>(_ type: WatchedType, period: Period = .weekly, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTask? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = try? mutableRequest(forPath: "\(type)/watched/\(period.rawValue)",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Collected
    
    func getCollected<T: TraktObject>(_ type: WatchedType, period: Period = .weekly, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTask? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = try? mutableRequest(forPath: "\(type)/collected/\(period.rawValue)",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Anticipated
    
    func getAnticipated<T: TraktObject>(_ type: WatchedType, pagination: Pagination?, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<T>) -> URLSessionDataTask? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = try? mutableRequest(forPath: "\(type)/anticipated",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Updates
    
    func getUpdated(_ type: WatchedType, startDate: Date?, pagination: Pagination?, extended: [ExtendedType], completion: @escaping UpdateCompletionHandler) -> URLSessionDataTask? {

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
        
        guard let request = try? mutableRequest(forPath: path,
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Summary
    
    func getSummary<U: Decodable>(_ type: WatchedType, id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<U>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "\(type)/\(id)",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Aliases
    
    func getAliases(_ type: WatchedType, id: CustomStringConvertible, completion: @escaping AliasCompletionHandler) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "\(type)/\(id)/aliases",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Translations
    
    func getTranslations<U: TraktObject>(_ type: WatchedType, id: CustomStringConvertible, language: String?, completion: @escaping ObjectCompletionHandler<[U]>) -> URLSessionDataTask? {

        var path = "\(type)/\(id)/translations"
        if let language = language {
            path += "/\(language)"
        }
        
        guard let request = try? mutableRequest(forPath: path,
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Comments
    
    func getComments(_ type: WatchedType, id: CustomStringConvertible, pagination: Pagination?, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {

        var query: [String: String] = [:]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = try? mutableRequest(forPath: "\(type)/\(id)/comments",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - People
    
    func getPeople<Cast: Codable & Hashable, Crew: Codable & Hashable>(_ type: WatchedType, id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<CastAndCrew<Cast, Crew>>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "\(type)/\(id)/people",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Ratings
    
    func getRatings(_ type: WatchedType, id: CustomStringConvertible, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "\(type)/\(id)/ratings",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Related
    
    func getRelated<U>(_ type: WatchedType, id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<[U]>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "\(type)/\(id)/related",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Stats
    
    func getStatistics(_ type: WatchedType, id: CustomStringConvertible, completion: @escaping statsCompletionHandler) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "\(type)/\(id)/stats",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Watching
    
    func getUsersWatching(_ type: WatchedType, id: CustomStringConvertible, completion: @escaping ObjectCompletionHandler<[User]>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "\(type)/\(id)/watching",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
}
