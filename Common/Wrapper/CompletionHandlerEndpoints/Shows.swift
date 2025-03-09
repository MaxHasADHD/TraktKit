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
    public func getTrendingShows(pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping TrendingShowsCompletionHandler) -> URLSessionDataTask? {
        return getTrending(.Shows, pagination: pagination, extended: extended, filters: filters, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
     Returns the most popular shows. Popularity is calculated using the rating percentage and the number of ratings.
     
     📄 Pagination
     */
    @discardableResult
    public func getPopularShows(pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping paginatedCompletionHandler<TraktShow>) -> URLSessionDataTask? {
        return getPopular(.Shows, pagination: pagination, extended: extended, filters: filters, completion: completion)
    }
    
    // MARK: - Played
    
    /**
     Returns the most played (a single user can watch multiple episodes multiple times) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getPlayedShows(period: Period = .weekly, pagination: Pagination? = nil, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTask? {
        return getPlayed(.Shows, period: period, pagination: pagination, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
     Returns the most watched (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getWatchedShows(period: Period = .weekly, pagination: Pagination? = nil, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTask? {
        return getWatched(.Shows, period: period, pagination: pagination, completion: completion)
    }
    
    // MARK: - Collected
    
    /**
     Returns the most collected (unique episodes per unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getCollectedShows(period: Period = .weekly, pagination: Pagination? = nil, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTask? {
        return getCollected(.Shows, pagination: pagination, completion: completion)
    }
    
    // MARK: - Anticipated
    
    /**
     Returns the most anticipated shows based on the number of lists a show appears on.
     
     📄 Pagination
     */
    @discardableResult
    public func getAnticipatedShows(period: Period = .weekly, pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], completion: @escaping AnticipatedShowCompletionHandler) -> URLSessionDataTask? {
        return getAnticipated(.Shows, pagination: pagination, extended: extended, completion: completion)
    }
    
    // MARK: - Updates
    
    /**
     Returns all shows updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.
     
     📄 Pagination
     */
    @discardableResult
    public func getUpdatedShows(startDate: Date?, pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<Update>) -> URLSessionDataTask? {
        return getUpdated(.Shows, startDate: startDate, pagination: pagination, extended: extended, completion: completion)
    }
    
    // MARK: - Updated IDs
    
    /**
     Returns all show Trakt IDs updated since the specified UTC date and time. We recommended storing the X-Start-Date header you can be efficient using this method moving forward. By default, 10 results are returned. You can send a limit to get up to 100 results per page.
     
     */
    @discardableResult
    public func getUpdatedShowTraktIds(from startDate: Date, pagination: Pagination? = nil, completion: @escaping paginatedCompletionHandler<Int>)  -> URLSessionDataTask? {
        var query = [String: String]()

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }
        let path = "shows/updates/id/\(startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? startDate.dateString(withFormat: "yyyy-MM-dd"))"
        guard let request = try? mutableRequest(forPath: path,
                                           withQuery: query,
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Summary
    
    /**
     Returns a single shows's details. If you get extended info, the `airs` object is relative to the show's country. You can use the `day`, `time`, and `timezone` to construct your own date then convert it to whatever timezone your user is in.
     
     **Note**: When getting `full` extended info, the `status` field can have a value of `returning series` (airing right now), `in production` (airing soon), `planned` (in development), `canceled`, or `ended`.
    */
    @discardableResult
    public func getShowSummary(showID id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktShow>) -> URLSessionDataTask? {
        return getSummary(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Aliases
    
    /**
     Returns all title aliases for a show. Includes country where name is different.
     
     - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
     */
    @discardableResult
    public func getShowAliases(showID id: CustomStringConvertible, completion: @escaping ObjectCompletionHandler<[Alias]>) -> URLSessionDataTask? {
        return getAliases(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Translations
    
    /**
    Returns all translations for a show, including language and translated values for title and overview.
    
    - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
    - parameter language: 2 character language code. Example: `es`
     */
    @discardableResult
    public func getShowTranslations(showID id: CustomStringConvertible, language: String?, completion: @escaping ShowTranslationsCompletionHandler) -> URLSessionDataTask? {
        return getTranslations(.Shows, id: id, language: language, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
     Returns all top level comments for a show. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getShowComments(showID id: CustomStringConvertible, pagination: Pagination? = nil, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        return getComments(.Shows, id: id, pagination: pagination, completion: completion)
    }

    // MARK: - Lists

    /**
     Returns all lists that contain this show. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    @discardableResult
    public func getListsContainingShow(showID id: CustomStringConvertible, listType: ListType? = nil, sortBy: ListSortType? = nil, pagination: Pagination? = nil, completion: @escaping ObjectCompletionHandler<[TraktList]>) -> URLSessionDataTask? {
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

        guard let request = try? mutableRequest(forPath: path,
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
    public func getShowCollectionProgress(showID id: CustomStringConvertible, hidden: Bool = false, specials: Bool = false, completion: @escaping ObjectCompletionHandler<ShowCollectionProgress>) -> URLSessionDataTask? {
        guard
            let request = try? mutableRequest(forPath: "shows/\(id)/progress/collection",
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
    public func getShowWatchedProgress(showID id: CustomStringConvertible, hidden: Bool = false, specials: Bool = false, completion: @escaping ShowWatchedProgressCompletionHandler) -> URLSessionDataTask? {
        guard
            let request = try? mutableRequest(forPath: "shows/\(id)/progress/watched",
                                         withQuery: ["hidden": "\(hidden)",
                                                     "specials": "\(specials)"],
                                         isAuthorized: true,
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
    public func getPeopleInShow(showID id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<CastAndCrew<TVCastMember, TVCrewMember>>) -> URLSessionDataTask? {
        return getPeople(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
     Returns rating (between 0 and 10) and distribution for a show.
     */
    @discardableResult
    public func getShowRatings(showID id: CustomStringConvertible, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTask? {
        return getRatings(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Related
    
    /**
     Returns related and similar shows. By default, 10 related shows will returned. You can send a `limit` to get up to `100` items.
     
     **Note**: We are continuing to improve this algorithm.
     */
    @discardableResult
    public func getRelatedShows(showID id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<[TraktShow]>) -> URLSessionDataTask? {
        return getRelated(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
     Returns lots of show stats.
     */
    @discardableResult
    public func getShowStatistics(showID id: CustomStringConvertible, completion: @escaping statsCompletionHandler) -> URLSessionDataTask? {
        return getStatistics(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
     Returns all users watching this show right now.
     */
    @discardableResult
    public func getUsersWatchingShow(showID id: CustomStringConvertible, completion: @escaping ObjectCompletionHandler<[User]>) -> URLSessionDataTask? {
        return getUsersWatching(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Next Episode
    
    /**
     Returns the next scheduled to air episode.
     
     **Note**: If no episode is found, a 204 HTTP status code will be returned.
     */
    @discardableResult
    public func getNextEpisode(showID id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktEpisode>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "shows/\(id)/next_episode",
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
    public func getLastEpisode(showID id: CustomStringConvertible, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktEpisode>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "shows/\(id)/last_episode",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
}
