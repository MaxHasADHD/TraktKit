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
    
    func getTrending<T: TraktProtocol>(_ type: WatchedType, page: Int, limit: Int, extended: ExtendedType = .Min, completion: ((result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("\(type)/trending?page=\(page)&limit=\(limit)&extended=\(extended)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Popular
    
    func getPopular<T: TraktProtocol>(_ type: WatchedType, page: Int, limit: Int, extended: ExtendedType = .Min,  completion: ((result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("\(type)/popular?page=\(page)&limit=\(limit)&extended=\(extended)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Played
    
    func getPlayed<T: TraktProtocol>(_ type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ((result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("\(type)/played/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else {
            return nil
        }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watched
    
    func getWatched<T: TraktProtocol>(_ type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ((result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("\(type)/watched/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Collected
    
    func getCollected<T: TraktProtocol>(_ type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ((result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("\(type)/collected/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Anticipated
    
    func getAnticipated(_ type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("\(type)/anticipated/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Updates
    
    func getUpdated(_ type: WatchedType, page: Int, limit: Int, startDate: String, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("\(type)/updates/\(startDate)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Summary
    
    func getSummary<T: CustomStringConvertible, U: TraktProtocol>(_ type: WatchedType, id: T, extended: ExtendedType = .Min, completion: ((result: ObjectResultType<U>) -> Void)) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)?extended=\(extended.rawValue)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Aliases
    
    func getAliases<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Translations
    
    func getTranslations<T: CustomStringConvertible, U: TraktProtocol>(_ type: WatchedType, id: T, language: String?, completion: ((result: ObjectsResultType<U>) -> Void)) -> URLSessionDataTask? {
        var path = "\(type)/\(id)/translations"
        if let language = language {
            path += "/\(language)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Comments
    
    func getComments<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: CommentsCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/comments", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - People
    
    func getPeople<T: CustomStringConvertible>(_ type: WatchedType, id: T, extended: ExtendedType = .Min, completion: CastCrewCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/people?extended=\(extended.rawValue)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Ratings
    
    func getRatings<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: ResultCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/ratings", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Related
    
    func getRelated<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/related", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Stats
    
    func getStatistics<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: statsCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/stats", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watching
    
    func getUsersWatching<T: CustomStringConvertible>(_ type: WatchedType, id: T, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/watching", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
