//
//  Shows.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/26/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

public enum Period: String {
    case Weekly = "weekly"
    case Monthly = "monthly"
    case All = "all"
}

extension TraktManager {
    
    // MARK: - Trending
    
    /**
     Returns all shows being watched right now. Shows with the most users are returned first.
     
     📄 Pagination
     */
    public func getTrendingShows(page page: Int, limit: Int, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getTrending(.Shows, page: page, limit: limit, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
     Returns the most popular shows. Popularity is calculated using the rating percentage and the number of ratings.
     
     📄 Pagination
    */
    public func getPopularShows(page page: Int, limit: Int, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getPopular(.Shows, page: page, limit: limit, completion: completion)
    }
    
    // MARK: - Played
    
    /**
     Returns the most played (a single user can watch multiple episodes multiple times) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    public func getPlayedShows(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getPlayed(.Shows, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
     Returns the most watched (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    public func getWatchedShows(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getWatched(.Shows, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Collected
    
    /**
     Returns the most collected (unique episodes per unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    public func getCollectedShows(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getCollected(.Shows, page: page, limit: limit, completion: completion)
    }
    
    // MARK: - Anticipated
    
    /**
     Returns the most anticipated shows based on the number of lists a show appears on.
     
     📄 Pagination
     */
    public func getAnticipatedShows(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getAnticipated(.Shows, page: page, limit: limit, completion: completion)
    }
    
    // MARK: - Updates
    
    /**
     Returns all shows updated since the specified UTC date. We recommended storing the date you can be efficient using this method moving forward.
     
     📄 Pagination
     */
    public func getUpdatedShows(page page: Int, limit: Int, startDate: String, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getUpdated(.Shows, page: page, limit: limit, startDate: startDate, completion: completion)
    }
    
    // MARK: - Summary
    
    /**
     Returns a single shows's details. If you get extended info, the `airs` object is relative to the show's country. You can use the `day`, `time`, and `timezone` to construct your own date then convert it to whatever timezone your user is in.
     
     **Note**: When getting `full` extended info, the `status` field can have a value of `returning series` (airing right now), `in production` (airing soon), `planned` (in development), `canceled`, or `ended`.
    */
    public func getShowSummary<T: CustomStringConvertible>(showID id: T, extended: extendedType = .Min, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        return getSummary(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Aliases
    
    /**
     Returns all title aliases for a show. Includes country where name is different.
     
     - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
     */
    public func getShowAliases<T: CustomStringConvertible>(showID id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getAliases(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Translations
    
    /**
    Returns all translations for a show, including language and translated values for title and overview.
    
    - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
    - parameter language: 2 character language code. Example: `es`
     */
    public func getShowTranslations<T: CustomStringConvertible>(showID id: T, language: String?, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getTranslations(.Shows, id: id, language: language, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
     Returns all top level comments for a show. Most recent comments returned first.
     
     📄 Pagination
     */
    public func getShowComments<T: CustomStringConvertible>(showID id: T, completion: CommentsCompletionHandler) -> NSURLSessionDataTask? {
        return getComments(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Collection Progress
    
    /**
     Returns collection progress for show including details on all seasons and episodes. The `next_episode` will be the next episode the user should collect, if there are no upcoming episodes it will be set to `null`. By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.
     
     🔒 OAuth: Required
     */
    public func getShowCollectionProgress<T: CustomStringConvertible>(showID id: T, hidden: Bool = false, specials: Bool = false, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(id)/progress/collection?hidden=\(hidden)&specials=\(specials)", authorization: true, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watched Progress
    
    /**
     Returns watched progress for show including details on all seasons and episodes. The `next_episode` will be the next episode the user should watch, if there are no upcoming episodes it will be set to `null`. By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.
     
     🔒 OAuth: Required
     */
    public func getShowWatchedProgress<T: CustomStringConvertible>(showID id: T, hidden: Bool = false, specials: Bool = false, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("shows/\(id)/progress/watched?hidden=\(hidden)&specials=\(specials)", authorization: true, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - People
    
    /**
     Returns all `cast` and `crew` for a show. Each `cast` member will have a `character` and a standard `person` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `person` object.
     */
    public func getPeopleInShow<T: CustomStringConvertible>(showID id: T, extended: extendedType = .Min, completion: CastCrewCompletionHandler) -> NSURLSessionDataTask? {
        return getPeople(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
     Returns rating (between 0 and 10) and distribution for a show.
     */
    public func getShowRatings<T: CustomStringConvertible>(showID id: T, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        return getRatings(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Related
    
    /**
     Returns related and similar shows. By default, 10 related shows will returned. You can send a `limit` to get up to `100` items.
     
     **Note**: We are continuing to improve this algorithm.
     */
    public func getRelatedShows<T: CustomStringConvertible>(showID id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getRelated(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
     Returns lots of show stats.
     */
    public func getShowStatistics<T: CustomStringConvertible>(showID id: T, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        return getStatistics(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
     Returns all users watching this show right now.
     */
    public func getUsersWatchingShow<T: CustomStringConvertible>(showID id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getUsersWatching(.Shows, id: id, completion: completion)
    }
}
