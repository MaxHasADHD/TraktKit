//
//  Seasons.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/26/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Returns all seasons for a show including the number of episodes in each season.
     
     If you add `?extended=episodes` to the URL, it will return all episodes for all seasons.
     
     **Note**: This returns a lot of data, so please only use this method if you need it all!
     
     */
    @discardableResult
    public func getSeasons<T: CustomStringConvertible>(showID id: T, extended: ExtendedType = .Min, completion: SeasonsCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("shows/\(id)/seasons?extended=\(extended)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all episodes for a specific season of a show.
     */
    @discardableResult
    public func getEpisodesForSeason<T: CustomStringConvertible>(showID id: T, season: NSNumber, extended: ExtendedType = .Min, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("shows/\(id)/seasons/\(season)?extended=\(extended)", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all top level comments for a season. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getAllSeasonComments<T: CustomStringConvertible>(showID id: T, season: NSNumber, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("shows/\(id)/seasons/\(season)/comments", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns rating (between 0 and 10) and distribution for a season.
     */
    @discardableResult
    public func getSeasonRatings<T: CustomStringConvertible>(showID id: T, season: NSNumber, completion: ResultCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("shows/\(id)/seasons/\(season)/ratings", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns lots of season stats.
     */
    @discardableResult
    public func getSeasonStatistics<T: CustomStringConvertible>(showID id: T, season: NSNumber, completion: statsCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("shows/\(id)/seasons/\(season)/stats", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all users watching this season right now.
     */
    @discardableResult
    public func getUsersWatchingSeasons<T: CustomStringConvertible>(showID id: T, season: NSNumber, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequestForURL("shows/\(id)/seasons/\(season)/watching", authorization: false, HTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
