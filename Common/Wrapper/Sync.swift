//
//  Sync.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Returns dictionary of dates when content was last updated
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter completion: completion block
     
     - returns: URLSessionDataTaskProtocol?
     */
    @discardableResult
    public func lastActivities(completion: @escaping LastActivitiesCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "sync/last_activities",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Playback
    
    /**
     Whenever a scrobble is paused, the playback progress is saved. Use this progress to sync up playback across different media centers or apps. For example, you can start watching a movie in a media center, stop it, then resume on your tablet from the same spot. Each item will have the progress percentage between 0 and 100.
     
     You can optionally specify a type to only get movies or episodes.
     
     By default, all results will be returned. However, you can send a limit if you only need a few recent results for something like an "on deck" feature.
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter type: Possible Values: .Movies, .Episodes
     */
    @discardableResult
    public func getPlaybackProgress(type: WatchedType, completion: @escaping ObjectsCompletionHandler<PlaybackProgress>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "sync/playback/\(type)",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Remove a playback item from a user's playback progress list. A 404 will be returned if the id is invalid.
     
     Status Code: 204
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func removePlaybackItem<T: CustomStringConvertible>(id: T, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "sync/playback/\(id)",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .DELETE) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Collection
    
    /**
     Get all collected items in a user's collection. A collected item indicates availability to watch digitally or on physical media.
     
     Each `movie` object contains `collected_at` and `updated_at` timestamps. Since users can set custom dates when they collected movies, it is possible for `collected_at` to be in the past. We also include `updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the show if you see a newer timestamp.
     
     Each `show` object contains `last_collected_at` and last_updated_at timestamps. Since users can set custom dates when they collected episodes, it is possible for `last_collected_at` to be in the past. We also include `last_updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the show if you see a newer timestamp.
     
     If you add `?extended=metadata` to the URL, it will return the additional `media_type`, `resolution`, `audio`, `audio_channels` and `3d` metadata. It will use `null` if the metadata isn't set for an item.
     
     Status Code: 200
     
     🔒 OAuth: Required
     ✨ Extended Info
     */
    @discardableResult
    public func getCollection(type: WatchedType, extended: [ExtendedType] = [.Min], completion: @escaping CollectionCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "sync/collection/\(type)",
                                         withQuery: ["extended": extended.queryString()],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Add items to a user's collection. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be collected. If seasons are specified, all episodes in those seasons will be collected.
     
     Send a `collected_at` UTC datetime to mark items as collected in the past. You can also send additional metadata about the media itself to have a very accurate collection. Showcase what is available to watch from your epic HD DVD collection down to your downloaded iTunes movies.
     
     **Note**: You can resend items already in your collection and they will be updated with any new values. This includes the `collected_at` and any other metadata.
     
     Status Code: 201
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func addToCollection(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: @escaping ObjectCompletionHandler<AddToCollectionResult>) throws -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "sync/collection",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .POST) else { return nil }
        request.httpBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Remove one or more items from a user's collection.
     
     Status Code: 200
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func removeFromCollection(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: @escaping ObjectCompletionHandler<RemoveFromCollectionResult>) throws -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "sync/collection/remove",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .POST) else { return nil }
        request.httpBody = try createJsonData(movies: movies,
                                              shows: shows,
                                              episodes: episodes)
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: -
    
    /**
     Returns all movies or shows a user has watched sorted by most plays.
     
     If type is set to shows and you add `?extended=noseasons` to the URL, it won't return season or episode info.
     
     Each movie and show object contains `last_watched_at` and `last_updated_at` timestamps. Since users can set custom dates when they watched movies and episodes, it is possible for `last_watched_at` to be in the past. We also include last_updated_at to help sync Trakt data with your app. Cache this timestamp locally and only re-process the show if you see a newer timestamp.
     
     Status Code: 200
     
     🔒 OAuth: Required
     ✨ Extended Info
     
     - parameter type: which type of content to receive
     - parameter completion: completion handler
     */
    @discardableResult
    public func getWatchedShows(extended: [ExtendedType] = [.Min], completion: @escaping WatchedShowsCompletionHandler) -> URLSessionDataTaskProtocol? {
        
        guard
            let request = mutableRequest(forPath: "sync/watched/shows",
                                         withQuery: ["extended": extended.queryString()],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Returns all movies or shows a user has watched sorted by most plays.
     
     If type is set to shows and you add `?extended=noseasons` to the URL, it won't return season or episode info.
     
     Each movie and show object contains `last_watched_at` and `last_updated_at` timestamps. Since users can set custom dates when they watched movies and episodes, it is possible for `last_watched_at` to be in the past. We also include last_updated_at to help sync Trakt data with your app. Cache this timestamp locally and only re-process the show if you see a newer timestamp.
     
     Status Code: 200
     
     🔒 OAuth: Required
     ✨ Extended Info
     
     - parameter type: which type of content to receive
     - parameter completion: completion handler
     */
    @discardableResult
    public func getWatchedMovies(extended: [ExtendedType] = [.Min], completion: @escaping WatchedMoviesCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "sync/watched/movies",
                                         withQuery: ["extended": extended.queryString()],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - History
    
    /**
     Returns movies and episodes that a user has watched, sorted by most recent. You can optionally limit the type to `movies` or `episodes`. The id (64-bit integer) in each history item uniquely identifies the event and can be used to remove individual events by using the `/sync/history/remove` method. The action will be set to `scrobble`, `checkin`, or `watch`.
     
     Specify a `type` and trakt `id` to limit the history for just that item. If the `id` is valid, but there is no history, an empty array will be returned.
     
     🔒 OAuth: Required
     📄 Pagination
     ✨ Extended Info
     */
    @discardableResult
    public func getHistory(type: WatchedType? = nil, traktID: Int? = nil, startAt: Date? = nil, endAt: Date? = nil, extended: [ExtendedType] = [.Min], pagination: Pagination? = nil, completion: @escaping HistoryCompletionHandler) -> URLSessionDataTaskProtocol? {
        
        var query: [String: String] = ["extended": extended.queryString()]
        
        if let startDate = startAt {
            query["start_at"] = startDate.UTCDateString()
        }
        
        if let endDate = endAt {
            query["end_at"] = endDate.UTCDateString()
        }
        
        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }
        
        var path = "sync/history"
        if let type = type {
            path += "/\(type.rawValue)"
        }
        
        if let traktID = traktID {
            path += "/\(traktID)"
        }
        
        guard
            let request = mutableRequest(forPath: path,
                                         withQuery: query,
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Add items to a user's watch history. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be added. If seasons are specified, only episodes in those seasons will be added.
     
     Send a `watched_at` UTC datetime to mark items as watched in the past. This is useful for syncing past watches from a media center.
     
     Status Code: 201
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter completion: completion handler
     */
    @discardableResult
    public func addToHistory(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: @escaping SuccessCompletionHandler) throws -> URLSessionDataTaskProtocol? {
        
        // Request
        guard var request = mutableRequest(forPath: "sync/history",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .POST) else { return nil }
        request.httpBody = try createJsonData(movies: movies,
                                              shows: shows,
                                              episodes: episodes)
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Remove items from a user's watch history including all watches, scrobbles, and checkins. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be removed. If seasons are specified, only episodes in those seasons will be removed.
     
     You can also send a list of raw history `ids` (64-bit integers) to delete single plays from the watched history. The `/sync/history` method will return an individual `id` (64-bit integer) for each history item.
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter historyIDs: Array of history ids.
     - parameter completion: completion handler
     */
    @discardableResult
    public func removeFromHistory(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], historyIDs: [NSNumber]? = nil, completion: @escaping SuccessCompletionHandler) throws -> URLSessionDataTaskProtocol? {
        
        // Request
        guard var request = mutableRequest(forPath: "sync/history/remove",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .POST) else { return nil }
        
        request.httpBody = try createJsonData(movies: movies,
                                              shows: shows,
                                              episodes: episodes,
                                              ids: historyIDs)
        
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
     Get a user's ratings filtered by type. You can optionally filter for a specific rating between 1 and 10.
     
     🔒 OAuth: Required
     
     - parameter type: Possible values:  `movies`, `shows`, `seasons`, `episodes`.
     - parameter rating: Filter for a specific rating
     */
    @discardableResult
    public func getRatings(type: WatchedType, rating: NSInteger?, completion: @escaping RatingsCompletionHandler) -> URLSessionDataTaskProtocol? {
        var path = "sync/ratings/\(type)"
        if let rating = rating {
            path += "/\(rating)"
        }
        
        guard
            let request = mutableRequest(forPath: path,
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Rate one or more items. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be rated. If seasons are specified, all of those seasons will be rated.
     
     Send a `rated_at` UTC datetime to mark items as rated in the past. This is useful for syncing ratings from a media center.
     
     🔒 OAuth: Required
     
     - parameter rating: Between 1 and 10.
     - parameter ratedAt: Date when the item was rated.
     - parameter movies: Array of movie objects
     - parameter shows: Array of show objects
     - parameter episodes: Array of episode objects
     */
    @discardableResult
    public func addRatings(rating: NSNumber, ratedAt: Date, movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: @escaping ObjectCompletionHandler<AddRatingsResult>) throws -> URLSessionDataTaskProtocol? {
        
        // JSON
        var json = RawJSON()
        let ratedAtString = ratedAt.UTCDateString()
        
        // Movies
        var ratedMovies: [RawJSON] = []
        for var movie in movies {
            movie["rated_at"] = ratedAtString
            movie["rating"] = rating
            ratedMovies.append(movie)
        }
        json["movies"] = ratedMovies
        
        // Shows
        var ratedShows: [RawJSON] = []
        for var show in shows {
            show["rated_at"] = ratedAtString
            show["rating"] = rating
            ratedShows.append(show)
        }
        json["shows"] = ratedShows
        
        // Episodes
        var ratedEpisodes: [RawJSON] = []
        for var episode in episodes {
            episode["rated_at"] = ratedAtString
            episode["rating"] = rating
            ratedEpisodes.append(episode)
        }
        json["episodes"] = ratedEpisodes
        
        // Request
        guard var request = mutableRequest(forPath: "sync/ratings",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .POST) else { return nil }
        request.httpBody = try JSONSerialization.data(withJSONObject: json,
                                                      options: [])
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Remove ratings for one or more items.
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie object JSON strings
     - parameter shows: array of show object JSON strings
     - parameter episodes: array of episode object JSON strings
     */
    @discardableResult
    public func removeRatings(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: @escaping ObjectCompletionHandler<RemoveRatingsResult>) throws -> URLSessionDataTaskProtocol? {
        guard
            var request = mutableRequest(forPath: "sync/ratings/remove",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .POST) else { return nil }
        request.httpBody = try createJsonData(movies: movies,
                                              shows: shows,
                                              episodes: episodes)
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Watchlist
    
    /**
     Returns all items in a user's watchlist filtered by type.

     All list items are sorted by ascending `rank`. We also send `X-Sort-By` and `X-Sort-How` headers which can be used to custom sort the watchlist in your app based on the user's preference. Values for X-Sort-By include `rank`, `added`, `title`, `released`, `runtime`, `popularity`, `percentage`, and `votes`. Values for `X-Sort-How` include `asc` and `desc`.

     **AUTO REMOVAL**
     When an item is watched, it will be automatically removed from the watchlist. For shows and seasons, watching 1 episode will remove the entire show or season. **The watchlist should not be used as a list of what the user is actively watching.** Use a combination of the **\/sync/watched** and **\/shows/:id/progress** methods to get what the user is actively watching.

     🔒 OAuth Required
     📄 Pagination Optional
     ✨ Extended Info
     */
    @discardableResult
    public func getWatchlist(watchType: WatchedType, pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], completion: @escaping WatchlistCompletionHandler) -> URLSessionDataTaskProtocol? {

        var query: [String: String] = ["extended": extended.queryString()]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard let request = mutableRequest(forPath: "sync/watchlist/\(watchType.rawValue)",
                                         withQuery: query,
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Add one of more items to a user's watchlist. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be added. If seasons are specified, all of those seasons will be added.
     
     Status Code: 201
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func addToWatchlist(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: @escaping SuccessCompletionHandler) throws -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "sync/watchlist",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .POST) else { completion(.fail); return nil }
        request.httpBody = try createJsonData(movies: movies,
                                              shows: shows,
                                              episodes: episodes)
        return performRequest(request: request,
                              completion: completion)
    }
    
    /**
     Remove one or more items from a user's watchlist.
     
     Status Code: 201
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func removeFromWatchlist(movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: @escaping ObjectCompletionHandler<RemoveFromWatchlistResult>) throws -> URLSessionDataTaskProtocol? {
        guard var request = mutableRequest(forPath: "sync/watchlist/remove",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .POST) else { completion(.error(error: nil)); return nil }
        request.httpBody = try createJsonData(movies: movies,
                                              shows: shows,
                                              episodes: episodes)
        return performRequest(request: request,
                              completion: completion)
    }
}
