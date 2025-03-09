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
    public func getEpisodeSummary(showID id: CustomStringConvertible, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktEpisode>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
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
    public func getEpisodeTranslations(showID id: CustomStringConvertible, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, language: String? = nil, completion: @escaping ObjectCompletionHandler<[TraktEpisodeTranslation]>) -> URLSessionDataTask? {
        var path = "shows/\(id)/seasons/\(season)/episodes/\(episode)/translations"
        if let language = language {
            path += "/\(language)"
        }

        guard let request = try? mutableRequest(forPath: path,
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }

    // MARK: - Comments

    /**
     Returns all top level comments for an episode. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getEpisodeComments(showID id: CustomStringConvertible, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, pagination: Pagination? = nil, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {

        var query: [String: String] = [:]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = try? mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/comments",
            withQuery: query,
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }

    // MARK: - Lists

    /**
     Returns all lists that contain this episode. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    @discardableResult
    public func getListsContainingEpisode(showID id: CustomStringConvertible, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, listType: ListType? = nil, sortBy: ListSortType? = nil, pagination: Pagination? = nil, completion: @escaping paginatedCompletionHandler<TraktList>) -> URLSessionDataTask? {
        var path = "shows/\(id)/seasons/\(season)/episodes/\(episode)/lists"
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

        guard let request = try? mutableRequest(forPath: path,
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }

    // MARK: - Ratings

    /**
     Returns rating (between 0 and 10) and distribution for an episode.
     */
    @discardableResult
    public func getEpisodeRatings(showID id: CustomStringConvertible, seasonNumber: NSNumber, episodeNumber: NSNumber, completion: @escaping ObjectCompletionHandler<RatingDistribution>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "shows/\(id)/seasons/\(seasonNumber)/episodes/\(episodeNumber)/ratings",
            withQuery: [:],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }

    // MARK: - Stats

    /**
     Returns lots of episode stats.
     */
    @discardableResult
    public func getEpisodeStatistics(showID id: CustomStringConvertible, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: @escaping statsCompletionHandler) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/stats",
            withQuery: [:],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }

    // MARK: - Watching

    /**
     Returns all users watching this episode right now.
     */
    @discardableResult
    public func getUsersWatchingEpisode(showID id: CustomStringConvertible, seasonNumber season: NSNumber, episodeNumber episode: NSNumber, completion: @escaping ObjectCompletionHandler<[User]>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/watching",
            withQuery: [:],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - People
    
    /**
     ✨ **Extended Info**
     Returns all `cast` and `crew` for a show, including the `episode_count` for which they appears. Each `cast` member will have a `characters` array and a standard person object.
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, and `editing` (if there are people for those crew positions). Each of those members will have a `jobs` array and a standard `person` object.
     
     **Guest Stars**
     
     If you add `?extended=guest_stars` to the URL, it will return all guest stars that appeared in at least 1 episode of the show.
     
     **Note**: This returns a lot of data, so please only use this extended parameter if you actually need it!
     */
    @discardableResult
    public func getPeopleInEpisode(showID id: CustomStringConvertible, season: NSNumber, episode: NSNumber, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<CastAndCrew<TVCastMember, TVCrewMember>>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "shows/\(id)/seasons/\(season)/episodes/\(episode)/people",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
}
