//
//  Seasons.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/26/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {

    // MARK: - Summary
    
    /**
     Returns all seasons for a show including the number of episodes in each season.
     
     If you add `?extended=episodes` to the URL, it will return all episodes for all seasons.
     
     **Note**: This returns a lot of data, so please only use this method if you need it all!
     
     */
    @discardableResult
    public func getSeasons<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping SeasonsCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "shows/\(id)/seasons",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }

    // MARK: - Season

    /**
     Returns all episodes for a specific season of a show.TranslationsIf you'd like to included translated episode titles and overviews in the response, include the `translations` parameter in the URL. Include `all` languages by setting the parameter to all or use a specific 2 digit country language code to further limit it.

     **Note**: This returns a lot of data, so please only use this parameter if you actually need it!

     ✨ Extended
     */
    @discardableResult
    public func getEpisodesForSeason<T: CustomStringConvertible>(showID id: T, season: NSNumber, translatedInto language: String? = nil, extended: [ExtendedType] = [.Min], completion: @escaping EpisodesCompletionHandler) -> URLSessionDataTaskProtocol? {

        var query = ["extended": extended.queryString()]
        query["translations"] = language

        guard var request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)",
            withQuery: query,
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }

        request.cachePolicy = .reloadIgnoringCacheData
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }

    // MARK: - Comments

    /**
     Returns all top level comments for a season. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getAllSeasonComments<T: CustomStringConvertible>(showID id: T, season: NSNumber, pagination: Pagination? = nil, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTaskProtocol? {
        var query: [String: String] = [:]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard var request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/comments",
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }

    // MARK: - Lists

    /**
     Returns all lists that contain this season. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    @discardableResult
    public func getListsContainingSeason<T: CustomStringConvertible>(showID id: T, season: NSNumber, listType: ListType? = nil, sortBy: ListSortType? = nil, pagination: Pagination? = nil, completion: @escaping paginatedCompletionHandler<TraktList>) -> URLSessionDataTaskProtocol? {
        var path = "shows/\(id)/seasons/\(season)/lists"
        if let listType = listType {
            path += "/\(listType)"

            if let sortBy = sortBy {
                path += "/\(sortBy)"
            }
        }

        var query: [String: String] = [:]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = mutableRequest(forPath: path,
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }

    // MARK: - Ratings

    /**
     Returns rating (between 0 and 10) and distribution for a season.
     */
    @discardableResult
    public func getSeasonRatings<T: CustomStringConvertible>(showID id: T, season: NSNumber, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/ratings",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }

    // MARK: - Stats

    /**
     Returns lots of season stats.
     */
    @discardableResult
    public func getSeasonStatistics<T: CustomStringConvertible>(showID id: T, season: NSNumber, completion: @escaping statsCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/stats",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }

    // MARK: - Watching

    /**
     Returns all users watching this season right now.
     */
    @discardableResult
    public func getUsersWatchingSeasons<T: CustomStringConvertible>(showID id: T, season: NSNumber, completion: @escaping ObjectsCompletionHandler<User>) -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/watching",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
