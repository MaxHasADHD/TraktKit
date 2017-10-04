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
    public func getTrendingShows(page: Int, limit: Int, extended: [ExtendedType] = [.Min], completion: @escaping TrendingShowsCompletionHandler) -> URLSessionDataTask? {
        return getTrending(.Shows, page: page, limit: limit, extended: extended, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
     Returns the most popular shows. Popularity is calculated using the rating percentage and the number of ratings.
     
     📄 Pagination
     */
    @discardableResult
    public func getPopularShows(page: Int, limit: Int, extended: [ExtendedType] = [.Min], completion: @escaping ObjectsCompletionHandler<TraktShow>) -> URLSessionDataTask? {
        return getPopular(.Shows, page: page, limit: limit, extended: extended, completion: completion)
    }
    
    // MARK: - Played
    
    /**
     Returns the most played (a single user can watch multiple episodes multiple times) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getPlayedShows(page: Int, limit: Int, period: Period = .Weekly, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTask? {
        return getPlayed(.Shows, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
     Returns the most watched (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getWatchedShows(page: Int, limit: Int, period: Period = .Weekly, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTask? {
        return getWatched(.Shows, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Collected
    
    /**
     Returns the most collected (unique episodes per unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     
     📄 Pagination
     */
    @discardableResult
    public func getCollectedShows(page: Int, limit: Int, period: Period = .Weekly, completion: @escaping MostShowsCompletionHandler) -> URLSessionDataTask? {
        return getCollected(.Shows, page: page, limit: limit, completion: completion)
    }
    
    // MARK: - Anticipated
    
    /**
     Returns the most anticipated shows based on the number of lists a show appears on.
     
     📄 Pagination
     */
    @discardableResult
    public func getAnticipatedShows(page: Int, limit: Int, period: Period = .Weekly, extended: [ExtendedType] = [.Min], completion: @escaping AnticipatedShowCompletionHandler) -> URLSessionDataTask? {
        return getAnticipated(.Shows, page: page, limit: limit, extended: extended, completion: completion)
    }
    
    // MARK: - Updates
    
    /**
     Returns all shows updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.
     
     📄 Pagination
     */
    @discardableResult
    public func getUpdatedShows(page: Int, limit: Int, startDate: Date?, completion: @escaping ObjectsCompletionHandler<Update>) -> URLSessionDataTask? {
        return getUpdated(.Shows, page: page, limit: limit, startDate: startDate, completion: completion)
    }
    
    // MARK: - Summary
    
    /**
     Returns a single shows's details. If you get extended info, the `airs` object is relative to the show's country. You can use the `day`, `time`, and `timezone` to construct your own date then convert it to whatever timezone your user is in.
     
     **Note**: When getting `full` extended info, the `status` field can have a value of `returning series` (airing right now), `in production` (airing soon), `planned` (in development), `canceled`, or `ended`.
    */
    @discardableResult
    public func getShowSummary<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<TraktShow>) -> URLSessionDataTask? {
        return getSummary(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Aliases
    
    /**
     Returns all title aliases for a show. Includes country where name is different.
     
     - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
     */
    @discardableResult
    public func getShowAliases<T: CustomStringConvertible>(showID id: T, completion: @escaping ObjectsCompletionHandler<Alias>) -> URLSessionDataTask? {
        return getAliases(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Translations
    
    /**
    Returns all translations for a show, including language and translated values for title and overview.
    
    - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
    - parameter language: 2 character language code. Example: `es`
     */
    @discardableResult
    public func getShowTranslations<T: CustomStringConvertible>(showID id: T, language: String?, completion: @escaping ShowTranslationsCompletionHandler) -> URLSessionDataTask? {
        return getTranslations(.Shows, id: id, language: language, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
     Returns all top level comments for a show. Most recent comments returned first.
     
     📄 Pagination
     */
    @discardableResult
    public func getShowComments<T: CustomStringConvertible>(showID id: T, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        return getComments(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Collection Progress
    
    /**
     Returns collection progress for show including details on all seasons and episodes. The `next_episode` will be the next episode the user should collect, if there are no upcoming episodes it will be set to `null`. By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func getShowCollectionProgress<T: CustomStringConvertible>(showID id: T, hidden: Bool = false, specials: Bool = false, completion: @escaping ObjectCompletionHandler<ShowCollectionProgress>) -> URLSessionDataTask? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/progress/collection",
                                         withQuery: ["hidden": "\(hidden)",
                                                     "specials": "\(specials)"],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watched Progress
    
    /**
     Returns watched progress for show including details on all seasons and episodes. The `next_episode` will be the next episode the user should watch, if there are no upcoming episodes it will be set to `null`. By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func getShowWatchedProgress<T: CustomStringConvertible>(showID id: T, hidden: Bool = false, specials: Bool = false, completion: @escaping ShowWatchedProgressCompletionHandler) -> URLSessionDataTask? {
        guard
            let request = mutableRequest(forPath: "shows/\(id)/progress/watched",
                                         withQuery: ["hidden": "\(hidden)",
                                                     "specials": "\(specials)"],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - People
    
    /**
     Returns all `cast` and `crew` for a show. Each `cast` member will have a `character` and a standard `person` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `person` object.
     */
    @discardableResult
    public func getPeopleInShow<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        return getPeople(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
     Returns rating (between 0 and 10) and distribution for a show.
     */
    @discardableResult
    public func getShowRatings<T: CustomStringConvertible>(showID id: T, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTask? {
        return getRatings(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Related
    
    /**
     Returns related and similar shows. By default, 10 related shows will returned. You can send a `limit` to get up to `100` items.
     
     **Note**: We are continuing to improve this algorithm.
     */
    @discardableResult
    public func getRelatedShows<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectsCompletionHandler<TraktShow>) -> URLSessionDataTask? {
        return getRelated(.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
     Returns lots of show stats.
     */
    @discardableResult
    public func getShowStatistics<T: CustomStringConvertible>(showID id: T, completion: @escaping statsCompletionHandler) -> URLSessionDataTask? {
        return getStatistics(.Shows, id: id, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
     Returns all users watching this show right now.
     */
    @discardableResult
    public func getUsersWatchingShow<T: CustomStringConvertible>(showID id: T, completion: @escaping ObjectsCompletionHandler<User>) -> URLSessionDataTask? {
        return getUsersWatching(.Shows, id: id, completion: completion)
    }
}
