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
    public func getSeasons(showID: NSNumber, extended: extendedType = .Min, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(showID)/seasons?extended=\(extended.rawValue)", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Returns all episodes for a specific season of a show.
     */
    public func getEpisodesForSeason(showID: NSNumber, season: NSNumber, extended: extendedType = .Min, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(showID)/seasons/\(season)?extended=\(extended.rawValue)", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Returns all top level comments for a season. Most recent comments returned first.
     
     📄 Pagination
     */
    public func getAllSeasonComments(showID: NSNumber, season: NSNumber, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(showID)/seasons/\(season)/comments", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Returns rating (between 0 and 10) and distribution for a season.
    */
    public func getSeasonRatings(showID: NSNumber, season: NSNumber, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(showID)/seasons/\(season)/ratings", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Returns lots of season stats.
     */
    public func getSeasonStatistics(showID: NSNumber, season: NSNumber, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(showID)/seasons/\(season)/stats", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Returns all users watching this season right now.
     */
    public func getUsersWatchingSeasons(showID: NSNumber, season: NSNumber, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(showID)/seasons/\(season)/watching", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
}
