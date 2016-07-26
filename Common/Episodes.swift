//
//  Episodes.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/26/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    // TODO: Hold a private variable that constructs the common base URL
    
    /**
     Returns a single episode's details. All date and times are in UTC and were calculated using the episode's `air_date` and show's `country` and `air_time`.
     
     **Note**: If the `first_aired` is unknown, it will be set to `null`.
     */
    @discardableResult
    public func getEpisodeSummary<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: ResultCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)", withQuery: [:], isAuthorized: false, withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all top level comments for an episode. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getEpisodeComments<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: CommentsCompletionHandler) -> URLSessionDataTask? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/comments",
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns rating (between 0 and 10) and distribution for an episode.
     */
    @discardableResult
    public func getEpisodeRatings<T: CustomStringConvertible>(showID id: T, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: ResultCompletionHandler) -> URLSessionDataTask? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/ratings",
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns lots of episode stats.
     */
    @discardableResult
    public func getEpisodeStatistics<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: statsCompletionHandler) -> URLSessionDataTask? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/stats",
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all users watching this episode right now.
     */
    @discardableResult
    public func getUsersWatchingEpisode<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: ArrayCompletionHandler) -> URLSessionDataTask? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/watching",
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
