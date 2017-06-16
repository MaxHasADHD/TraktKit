//
//  SharedFunctions.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/27/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

private typealias ShowsAndMovies = TraktManager
internal extension ShowsAndMovies {
    
    // MARK: - Trending
    
    func getTrending<T>(_ type: WatchedType, page: Int, limit: Int, extended: [ExtendedType] = [.Min], completion: @escaping ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "\(type)/trending",
                                           withQuery: [
                                            "page": "\(page)",
                                            "limit": "\(limit)",
                                            "extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Popular
    
    func getPopular<T>(_ type: WatchedType, page: Int, limit: Int, extended: [ExtendedType] = [.Min],  completion: @escaping ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "\(type)/popular",
                                           withQuery: ["page": "\(page)",
                                                       "limit": "\(limit)",
                                                       "extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Played
    
    func getPlayed<T>(_ type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: @escaping ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "\(type)/played/\(period.rawValue)",
                                           withQuery: ["page": "\(page)",
                                                       "limit": "\(limit)"],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watched
    
    func getWatched<T>(_ type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: @escaping ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "\(type)/watched/\(period.rawValue)",
                                           withQuery: ["page": "\(page)",
                                                       "limit": "\(limit)"],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Collected
    
    func getCollected<T>(_ type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: @escaping ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "\(type)/collected/\(period.rawValue)",
                                           withQuery: ["page": "\(page)",
                                                       "limit": "\(limit)"],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Anticipated
    
    func getAnticipated<U>(_ type: WatchedType, page: Int, limit: Int, extended: [ExtendedType] = [.Min], completion: @escaping ((_ result: ObjectsResultType<U>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "\(type)/anticipated",
                                           withQuery: ["page": "\(page)",
                                                       "limit": "\(limit)",
                                                       "extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Updates
    
    func getUpdated(_ type: WatchedType, page: Int, limit: Int, startDate: Date?, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        
        var path = "\(type)/updates/"
        if let startDateString = startDate?.dateString(withFormat: "YYYY-MM-DD") {
            path.append(startDateString)
        }
        
        guard var request = mutableRequest(forPath: path,
                                           withQuery: ["page": "\(page)",
                                                       "limit": "\(limit)"],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Summary
    
    func getSummary<T: CustomStringConvertible, U>(_ type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<U>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Aliases
    
    func getAliases<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Translations
    
    func getTranslations<T: CustomStringConvertible, U>(_ type: WatchedType, id: T, language: String?, completion: @escaping ((_ result: ObjectsResultType<U>) -> Void)) -> URLSessionDataTask? {
        
        var path = "\(type)/\(id)/translations"
        if let language = language {
            path += "/\(language)"
        }
        
        guard let request = mutableRequest(forPath: path,
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Comments
    
    func getComments<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/comments",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - People
    
    func getPeople<T: CustomStringConvertible>(_ type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/people",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Ratings
    
    func getRatings<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping ResultCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/ratings",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Related
    
    func getRelated<T: CustomStringConvertible, U>(_ type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping ((_ result: ObjectsResultType<U>) -> Void)) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/related",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Stats
    
    func getStatistics<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping statsCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/stats",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watching
    
    func getUsersWatching<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "\(type)/\(id)/watching",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
