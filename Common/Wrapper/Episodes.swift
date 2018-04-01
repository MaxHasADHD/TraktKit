//
//  Episodes.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/26/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {

    // MARK: - Summary
    
    /**
     Returns a single episode's details. All date and times are in UTC and were calculated using the episode's `air_date` and show's `country` and `air_time`.
     
     **Note**: If the `first_aired` is unknown, it will be set to `null`.
     */
    @discardableResult
    public func getEpisodeSummary<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktEpisode>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }

    // MARK: - Translations

    /**
     Returns all translations for an episode, including language and translated values for title and overview.

     - parameter showID: Trakt.tv ID, Trakt.tv slug, or IMDB ID
     - parameter seasonNumber: season number
     - parameter episodeNumber: episode number
     - parameter language: 2 character language code
     */
    @discardableResult
    public func getEpisodeTranslations<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, language: String? = nil, completion: @escaping ObjectsCompletionHandler<TraktEpisodeTranslation>) -> URLSessionDataTaskProtocol? {
        var path = "shows/\(id)/seasons/\(season)/episodes/\(episode)/translations"
        if let language = language {
            path += "/\(language)"
        }

        guard let request = mutableRequest(forPath: path,
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }

    // MARK: - Comments

    /**
     Returns all top level comments for an episode. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getEpisodeComments<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTaskProtocol? {

        guard let request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/comments",
            withQuery: [:],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }

    // MARK: - Lists

    /**
     Returns all lists that contain this episode. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    @discardableResult
    public func getListsContainingEpisode<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, listType: ListType? = nil, sortBy: ListSortType? = nil, completion: @escaping ObjectsCompletionHandler<TraktList>) -> URLSessionDataTaskProtocol? {
        var path = "shows/\(id)/seasons/\(season)/episodes/\(episode)/lists"
        if let listType = listType {
            path += "/\(listType)"

            if let sortBy = sortBy {
                path += "/\(sortBy)"
            }
        }

        guard let request = mutableRequest(forPath: path,
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }

    // MARK: - Ratings

    /**
     Returns rating (between 0 and 10) and distribution for an episode.
     */
    @discardableResult
    public func getEpisodeRatings<T: CustomStringConvertible>(showID id: T, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: @escaping ObjectCompletionHandler<RatingDistribution>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "shows/\(id)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/ratings",
            withQuery: [:],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }

    // MARK: - Stats

    /**
     Returns lots of episode stats.
     */
    @discardableResult
    public func getEpisodeStatistics<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: @escaping statsCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/stats",
            withQuery: [:],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }

    // MARK: - Watching

    /**
     Returns all users watching this episode right now.
     */
    @discardableResult
    public func getUsersWatchingEpisode<T: CustomStringConvertible>(showID id: T, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: @escaping ObjectsCompletionHandler<User>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/watching",
            withQuery: [:],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }
}
