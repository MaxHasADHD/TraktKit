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
     
     - returns: NSURLSessionDataTask?
     */
    public func lastActivities(completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/last_activities", authorization: true, HTTPMethod: .GET) else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
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
    public func getPlaybackProgress(type: WatchedType, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/playback/\(type)", authorization: true, HTTPMethod: .GET) else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Remove a playback item from a user's playback progress list. A 404 will be returned if the id is invalid.
     
     Status Code: 204
     
     🔒 OAuth: Required
    */
    public func removePlaybackItem<T: CustomStringConvertible>(id: T, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/playback/\(id)", authorization: true, HTTPMethod: .DELETE) else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNoContentToReturn, completion: completion)
    }
    
    // MARK: - Collection
    
    /**
     Get all collected items in a user's collection. A collected item indicates availability to watch digitally or on physical media.
     
     If you add `?extended=metadata` to the URL, it will return the additional `media_type`, `resolution`, `audio`, `audio_channels` and '3d' metadata. It will use `null` if the metadata isn't set for an item.
     
     Status Code: 200
     
     🔒 OAuth: Required
    */
    public func getCollection(type: WatchedType, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection/\(type)", authorization: true, HTTPMethod: .GET) else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Add items to a user's collection. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be collected. If seasons are specified, all episodes in those seasons will be collected.
     
     Send a `collected_at` UTC datetime to mark items as collected in the past. You can also send additional metadata about the media itself to have a very accurate collection. Showcase what is available to watch from your epic HD DVD collection down to your downloaded iTunes movies.
     
     **Note**: You can resend items already in your collection and they will be updated with any new values. This includes the `collected_at` and any other metadata.
     
     Status Code: 201
     
     🔒 OAuth: Required
     */
    public func addToCollection(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection", authorization: true, HTTPMethod: .POST) else {
            return nil
        }
        request.HTTPBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNewResourceCreated, completion: completion)
    }
    
    /**
     Remove one or more items from a user's collection.
     
     Status Code: 200
     
     🔒 OAuth: Required
     */
    public func removeFromCollection(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection/remove", authorization: true, HTTPMethod: .POST) else { return nil }
        request.HTTPBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: -
    
    /**
     Returns all movies or shows a user has watched.
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter type: which type of content to receive
     
     - parameter completion: completion handler
     */
    public func getWatched(type: WatchedType, extended: extendedType = .Min, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        
        // Used to check data from another Trakt acount
//        guard let request = mutableRequestForURL("users/USERNAME/watched/shows?extended=full", authorization: true, HTTPMethod: .GET) else {
//            return nil
//        }
        
        guard let request = mutableRequestForURL("sync/watched/\(type.rawValue)?extended=\(extended.rawValue)", authorization: true, HTTPMethod: .GET) else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - History
    
    /**
     Returns movies and episodes that a user has watched, sorted by most recent. You can optionally limit the `type` to `movies` or `episodes`. The `id` in each history item uniquely identifies the event and can be used to remove individual events by using the POST /sync/history/remove method. The action will be set to scrobble, checkin, or watch.
     
     Specify a type and trakt id to limit the history for just that item. If the id is valid, but there is no history, an empty array will be returned.
    
    🔒 OAuth: Required
     */
    public func getHistory<T: CustomStringConvertible>(type: WatchedType?, traktID: T?, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        var path = "sync/history"
        if let type = type {
            path += type.rawValue
        }
        
        if let traktID = traktID {
            path += "\(traktID)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: true, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Add items to a user's watch history.
     
     Status Code: 201
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter completion: completion handler
     */
    public func addToHistory(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        
        // Request
        guard let request = mutableRequestForURL("sync/history", authorization: true, HTTPMethod: .POST) else {
            completion(result: TraktManager.DictionaryResultType.Error(error: nil))
            return nil
        }
        request.HTTPBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNewResourceCreated, completion: completion)
    }
    
    /**
     Removes items from a user's watch history including watches, scrobbles, and checkins.
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter completion: completion handler
     */
    public func removeFromHistory(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: SuccessCompletionHandler) throws -> NSURLSessionDataTask? {
        
        // Request
        guard let request = mutableRequestForURL("sync/history/remove", authorization: true, HTTPMethod: .POST) else {
            return nil
        }
        request.HTTPBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
     Get a user's ratings filtered by type. You can optionally filter for a specific rating between 1 and 10.
    
    🔒 OAuth: Required
    
    - parameter type: Possible values:  `movies`, `shows`, `seasons`, `episodes`.
    - parameter rating: Filter for a specific rating
    */
    public func getRatings(type: WatchedType, rating: NSInteger?, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        var path = "sync/ratings/\(type)"
        if let rating = rating {
            path += "/\(rating)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: true, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Rate one or more items. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be rated. If seasons are specified, all of those seasons will be rated.
     
     Send a `rated_at` UTC datetime to mark items as rated in the past. This is useful for syncing ratings from a media center.
     
     🔒 OAuth: Required
     
     - parameter rating: Between 1 and 10.
     - parameter ratedAt: UTC datetime when the item was rated.
     - parameter movies: Array of movie objects
     - parameter shows: Array of show objects
     - parameter episodes: Array of episode objects
    */
    public func addRatings(rating rating: NSNumber, ratedAt: String, movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        
        // TODO: Replace ratedAt parameter to be a NSDate and convert to UTC time
        
        // JSON
        var json = RawJSON()
        
        // Movies
        var ratedMovies: [RawJSON] = []
        for var movie in movies {
            movie["rated_at"] = ratedAt
            movie["rating"] = movie
            ratedMovies.append(movie)
        }
        json["movies"] = ratedMovies
        
        // Shows
        var ratedShows: [RawJSON] = []
        for var show in shows {
            show["rated_at"] = ratedAt
            show["rating"] = rating
            ratedShows.append(show)
        }
        json["shows"] = ratedShows
        
        // Episodes
        var ratedEpisodes: [RawJSON] = []
        for var episode in episodes {
            episode["rated_at"] = ratedAt
            episode["rating"] = rating
            ratedEpisodes.append(episode)
        }
        json["episodes"] = ratedEpisodes
        
        // Request
        guard let request = mutableRequestForURL("sync/ratings", authorization: true, HTTPMethod: .POST) else { return nil }
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNewResourceCreated, completion: completion)
    }
    
    /**
     Remove ratings for one or more items.
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie object JSON strings
     - parameter shows: array of show object JSON strings
     - parameter episodes: array of episode object JSON strings
    */
    public func removeRatings(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/ratings/remove", authorization: true, HTTPMethod: .POST) else { return nil }
        request.HTTPBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Watchlist
    
    /**
     Returns all items in a user's watchlist filtered by type. When an item is watched, it will be automatically removed from the watchlist. To track what the user is actively watching, use the progress APIs.
    */
    public func getWatchlist(watchType: WatchedType, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/watchlist", authorization: true, HTTPMethod: .GET) else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Add one of more items to a user's watchlist. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be added. If seasons are specified, all of those seasons will be added.
     
     Status Code: 201
     
     🔒 OAuth: Required
    */
    public func addToWatchlist(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: SuccessCompletionHandler) throws -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/watchlist", authorization: true, HTTPMethod: .POST) else {
            completion(result: .Fail)
            return nil
        }
        request.HTTPBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNewResourceCreated, completion: completion)
    }
    
    /**
     Remove one or more items from a user's watchlist.
     
     Status Code: 201
     
     🔒 OAuth: Required
     */
    public func removeFromWatchlist(movies movies: [RawJSON], shows: [RawJSON], episodes: [RawJSON], completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/watchlist/remove", authorization: true, HTTPMethod: .POST) else {
            completion(result: .Error(error: nil))
            return nil
        }
        request.HTTPBody = try createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
