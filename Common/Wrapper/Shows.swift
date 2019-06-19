//
//  Shows.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/26/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Trending
    
    /**
     Returns all shows being watched right now. Shows with the most users are returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getTrendingShows(pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping TrendingShowsCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getTrending(.Shows, pagination: pagination, extended: extended, filters: filters, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
     Returns the most popular shows. Popularity is calculated using the rating percentage and the number of ratings.
     
     📄 Pagination
     */
    @discardableResult
    public func getPopularShows(pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping paginatedCompletionHandler<TraktShow>) -> URLSessionDataTaskProtocol? {
        return getPopular(.Shows, pagination: pagination, extended: extended, filters: filters, completion: completion)
    }
    
    // MARK: - Played
    
    /**
     Returns the most played (a single user can watch multiple episodes multiple times) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getPlayedShows(period: Period = .Weekly, pagination: Pagination? = nil, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getPlayed(.Shows, period: period, pagination: pagination, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
     Returns the most watched (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getWatchedShows(period: Period = .Weekly, pagination: Pagination? = nil, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getWatched(.Shows, period: period, pagination: pagination, completion: completion)
    }
    
    // MARK: - Collected
    
    /**
     Returns the most collected (unique episodes per unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getCollectedShows(period: Period = .Weekly, pagination: Pagination? = nil, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getCollected(.Shows, pagination: pagination, completion: completion)
    }
    
    // MARK: - Anticipated
    
    /**
     Returns the most anticipated shows based on the number of lists a show appears on.
     
     📄 Pagination
     */
    @discardableResult
    public func getAnticipatedShows(period: Period = .Weekly, pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], completion: @escaping AnticipatedShowCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getAnticipated(.Shows, pagination: pagination, extended: extended, completion: completion)
    }
    
    // MARK: - Updates
    
    /**
     Returns all shows updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.
     
     📄 Pagination
     */
    @discardableResult
    public func getUpdatedShows(startDate: Date?, pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<Update>) -> URLSessionDataTaskProtocol? {
        return getUpdated(.Shows, startDate: startDate, pagination: pagination, extended: extended, completion: completion)
    }
    
    // MARK: - Summary
    
    /**
     Returns a single shows's details. If you get extended info, the `airs` object is relative to the show's country. You can use the `day`, `time`, and `timezone` to construct your own date then convert it to whatever timezone your user is in.
     
     **Note**: When getting `full` extended info, the `status` field can have a value of `returning series` (airing right now), `in production` (airing soon), `planned` (in development), `canceled`, or `ended`.
    */
    @discardableResult
    public func getShowSummary<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktShow>) -> URLSessionDataTaskProtocol? {
        return getSummary(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Aliases
    
    /**
     Returns all title aliases for a show. Includes country where name is different.
     
     - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
     */
    @discardableResult
    public func getShowAliases<T: CustomStringConvertible>(showID id: T, completion: @escaping ObjectsCompletionHandler<Alias>) -> URLSessionDataTaskProtocol? {
        return getAliases(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Translations
    
    /**
    Returns all translations for a show, including language and translated values for title and overview.
    
    - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
    - parameter language: 2 character language code. Example: `es`
     */
    @discardableResult
    public func getShowTranslations<T: CustomStringConvertible>(showID id: T, language: String?, completion: @escaping ShowTranslationsCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getTranslations(.Shows, id: id, language: language, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
     Returns all top level comments for a show. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getShowComments<T: CustomStringConvertible>(showID id: T, pagination: Pagination? = nil, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getComments(.Shows, id: id, pagination: pagination, completion: completion)
    }

    // MARK: - Lists

    /**
     Returns all lists that contain this show. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    @discardableResult
    public func getListsContainingShow<T: CustomStringConvertible>(showID id: T, listType: ListType? = nil, sortBy: ListSortType? = nil, pagination: Pagination? = nil, completion: @escaping ObjectsCompletionHandler<TraktList>) -> URLSessionDataTaskProtocol? {
        var path = "shows/\(id)/lists"
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
        return performRequest(request: request,
                              completion: completion)
    }

    // MARK: - Collection Progress
    
    /**
     Returns collection progress for show including details on all seasons and episodes. The `next_episode` will be the next episode the user should collect, if there are no upcoming episodes it will be set to `null`. By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func getShowCollectionProgress<T: CustomStringConvertible>(showID id: T, hidden: Bool = false, specials: Bool = false, completion: @escaping ObjectCompletionHandler<ShowCollectionProgress>) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/progress/collection",
                                         withQuery: ["hidden": "\(hidden)",
                                                     "specials": "\(specials)"],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Watched Progress
    
    /**
     Returns watched progress for show including details on all seasons and episodes. The `next_episode` will be the next episode the user should watch, if there are no upcoming episodes it will be set to `null`. By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func getShowWatchedProgress<T: CustomStringConvertible>(showID id: T, hidden: Bool = false, specials: Bool = false, completion: @escaping ShowWatchedProgressCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/progress/watched",
                                         withQuery: ["hidden": "\(hidden)",
                                                     "specials": "\(specials)"],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - People
    
    /**
     Returns all `cast` and `crew` for a show. Each `cast` member will have a `character` and a standard `person` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `person` object.
     */
    @discardableResult
    public func getPeopleInShow<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getPeople(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
     Returns rating (between 0 and 10) and distribution for a show.
     */
    @discardableResult
    public func getShowRatings<T: CustomStringConvertible>(showID id: T, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getRatings(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Related
    
    /**
     Returns related and similar shows. By default, 10 related shows will returned. You can send a `limit` to get up to `100` items.
     
     **Note**: We are continuing to improve this algorithm.
     */
    @discardableResult
    public func getRelatedShows<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectsCompletionHandler<TraktShow>) -> URLSessionDataTaskProtocol? {
        return getRelated(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
     Returns lots of show stats.
     */
    @discardableResult
    public func getShowStatistics<T: CustomStringConvertible>(showID id: T, completion: @escaping statsCompletionHandler) -> URLSessionDataTaskProtocol? {
        return getStatistics(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
     Returns all users watching this show right now.
     */
    @discardableResult
    public func getUsersWatchingShow<T: CustomStringConvertible>(showID id: T, completion: @escaping ObjectsCompletionHandler<User>) -> URLSessionDataTaskProtocol? {
        return getUsersWatching(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Next Episode
    
    /**
     Returns the next scheduled to air episode.
     
     **Note**: If no episode is found, a 204 HTTP status code will be returned.
     */
    @discardableResult
    public func getNextEpisode<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktEpisode>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "shows/\(id)/next_episode",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Last Episode
    
    /**
     Returns the most recently aired episode.
     
     **Note**: If no episode is found, a 204 HTTP status code will be returned.
     */
    @discardableResult
    public func getLastEpisode<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktEpisode>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "shows/\(id)/last_episode",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
}
