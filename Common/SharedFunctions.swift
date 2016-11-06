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
    
    func getTrending(type: WatchedType, page: Int, limit: Int, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/trending?page=\(page)&limit=\(limit)&extended=full,images", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Popular
    
    func getPopular(type: WatchedType, page: Int, limit: Int, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/popular?page=\(page)&limit=\(limit)&extended=full,images", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Played
    
    func getPlayed(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/played/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watched
    
    func getWatched(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/watched/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Collected
    
    func getCollected(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/collected/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Anticipated
    
    func getAnticipated(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/anticipated/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Updates
    
    func getUpdated(type: WatchedType, page: Int, limit: Int, startDate: String, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/updates/\(startDate)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Summary
    
    func getSummary<T: CustomStringConvertible>(type: WatchedType, id: T, extended: extendedType = .Min, completion: @escaping ResultCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL(path: "\(type)/\(id)?extended=\(extended.rawValue)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Aliases
    
    func getAliases<T: CustomStringConvertible>(type: WatchedType, id: T, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL(path: "\(type)/\(id)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Translations
    
    func getTranslations<T: CustomStringConvertible>(type: WatchedType, id: T, language: String?, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        var path = "\(type)/\(id)/translations"
        if let language = language {
            path += "/\(language)"
        }
        
        guard let request = mutableRequestForURL(path: path, authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Comments
    
    func getComments<T: CustomStringConvertible>(type: WatchedType, id: T, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL(path: "\(type)/\(id)/comments", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - People
    
    func getPeople<T: CustomStringConvertible>(type: WatchedType, id: T, extended: extendedType = .Min, completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL(path: "\(type)/\(id)/people?extended=\(extended.rawValue)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Ratings
    
    func getRatings<T: CustomStringConvertible>(type: WatchedType, id: T, completion: @escaping ResultCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL(path: "\(type)/\(id)/ratings", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Related
    
    func getRelated<T: CustomStringConvertible>(type: WatchedType, id: T, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL(path: "\(type)/\(id)/related", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Stats
    
    func getStatistics<T: CustomStringConvertible>(type: WatchedType, id: T, completion: @escaping ResultCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL(path: "\(type)/\(id)/stats", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watching
    
    func getUsersWatching<T: CustomStringConvertible>(type: WatchedType, id: T, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL(path: "\(type)/\(id)/watching", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
