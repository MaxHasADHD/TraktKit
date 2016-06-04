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
    
    func getTrending(type: WatchedType, page: Int, limit: Int, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/trending?page=\(page)&limit=\(limit)&extended=full,images", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Popular
    
    func getPopular(type: WatchedType, page: Int, limit: Int, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/popular?page=\(page)&limit=\(limit)&extended=full,images", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Played
    
    func getPlayed(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/played/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watched
    
    func getWatched(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/watched/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Collected
    
    func getCollected(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/collected/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Anticipated
    
    func getAnticipated(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/anticipated/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Updates
    
    func getUpdated(type: WatchedType, page: Int, limit: Int, startDate: String, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/updates/\(startDate)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Summary
    
    func getSummary<T: CustomStringConvertible>(type: WatchedType, id: T, extended: extendedType = .Min, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)?extended=\(extended.rawValue)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Aliases
    
    func getAliases<T: CustomStringConvertible>(type: WatchedType, id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Translations
    
    func getTranslations<T: CustomStringConvertible>(type: WatchedType, id: T, language: String?, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        var path = "\(type)/\(id)/translations"
        if let language = language {
            path += "/\(language)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Comments
    
    func getComments<T: CustomStringConvertible>(type: WatchedType, id: T, completion: CommentsCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/comments", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - People
    
    func getPeople<T: CustomStringConvertible>(type: WatchedType, id: T, extended: extendedType = .Min, completion: CastCrewCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/people?extended=\(extended.rawValue)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Ratings
    
    func getRatings<T: CustomStringConvertible>(type: WatchedType, id: T, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/ratings", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Related
    
    func getRelated<T: CustomStringConvertible>(type: WatchedType, id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/related", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Stats
    
    func getStatistics<T: CustomStringConvertible>(type: WatchedType, id: T, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/stats", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watching
    
    func getUsersWatching<T: CustomStringConvertible>(type: WatchedType, id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/watching", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}