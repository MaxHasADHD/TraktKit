//
//  Film.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Trending
    
    /**
    Returns all movies being watched right now. Movies with the most users are returned first.
    
    📄 Pagination
     */
    public func getTrendingMovies(page page: Int, limit: Int, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getTrending(.Movies, page: page, limit: limit, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
    Returns the most popular movies. Popularity is calculated using the rating percentage and the number of ratings.
    
    📄 Pagination
    */
    public func getPopularMovies(page page: Int, limit: Int, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getPopular(.Movies, page: page, limit: limit, completion: completion)
    }
    
    // MARK: - Played
    
    /**
    Returns the most played (a single user can watch multiple times) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    public func getPlayedMovies(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getPlayed(.Movies, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
    Returns the most watched (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    public func getWatchedMovies(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getWatched(.Movies, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Collected
    
    /**
    Returns the most collected (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    public func getCollectedMovies(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getCollected(.Movies, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Anticipated
    
    /**
    Returns the most anticipated movies based on the number of lists a movie appears on.
    
    📄 Pagination
    */
    public func getAnticipatedMovies(page page: Int, limit: Int, period: Period = .Weekly, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getAnticipated(.Movies, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Box Office
    
    /**
    Returns the top 10 grossing movies in the U.S. box office last weekend. Updated every Monday morning.
    */
    public func getWeekendBoxOffice(completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("movies/boxoffice", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Updates
    
    /**
    Returns all movies updated since the specified UTC date. We recommended storing the date you can be efficient using this method moving forward.
    
    📄 Pagination
    */
    public func getUpdatedMovies(page page: Int, limit: Int, startDate: String, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getUpdated(.Movies, page: page, limit: limit, startDate: startDate, completion: completion)
    }
    
    // MARK: - Summary
    
    /**
    Returns a single movie's details.
    */
    public func getMovieSummary(movieID id: NSNumber, extended: extendedType = .Min, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        return getSummary(.Movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Aliases
    
    /**
    Returns all title aliases for a movie. Includes country where name is different.
    */
    public func getMovieAliases<T: CustomStringConvertible>(movieID id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getAliases(.Movies, id: id, completion: completion)
    }
    
    // MARK: - Releases
    
    /**
    Returns all releases for a movie including country, certification, and release date.
    
    - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
    - parameter country: 2 character country code. Example: `us`.
    */
    public func getMovieReleases<T: CustomStringConvertible>(movieID id: T, country: String?, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        
        var path = "movies/\(id)/releases"
        
        if let country = country {
            path += "/\(country)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Translations
    
    /**
    Returns all translations for a movie, including language and translated values for title, tagline and overview.
    */
    public func getMovieTranslations<T: CustomStringConvertible>(movieID id: T, language: String?, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getTranslations(.Movies, id: id, language: language, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
    Returns all top level comments for a movie. Most recent comments returned first.
    
    📄 Pagination
    */
    public func getMovieComments<T: CustomStringConvertible>(movieID id: T, completion: CommentsCompletionHandler) -> NSURLSessionDataTask? {
        return getComments(.Movies, id: id, completion: completion)
    }
    
    // MARK: - People
    
    /**
    Returns all `cast` and `crew` for a movie. Each `cast` member will have a `character` and a standard `person` object.
    
    The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `person` object.
    */
    public func getPeopleInMovie<T: CustomStringConvertible>(movieID id: T, extended: extendedType = .Min, completion: CastCrewCompletionHandler) -> NSURLSessionDataTask? {
        return getPeople(.Movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
    Returns rating (between 0 and 10) and distribution for a movie.
    */
    public func getMovieRatings<T: CustomStringConvertible>(movieID id: T, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        return getRatings(.Movies, id: id, completion: completion)
    }
    
    // MARK: - Related
    
    /**
    Returns related and similar movies. By default, 10 related movies will returned. You can send a `limit` to get up to `100` items.
    
    **Note**: We are continuing to improve this algorithm.
    */
    public func getRelatedMovies<T: CustomStringConvertible>(movieID id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getRelated(.Movies, id: id, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
    Returns lots of movie stats.
    */
    public func getMovieStatistics<T: CustomStringConvertible>(movieID id: T, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        return getStatistics(.Movies, id: id, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
    Returns all users watching this movie right now.
    */
    public func getUsersWatchingMovie<T: CustomStringConvertible>(movieID id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        return getUsersWatching(.Movies, id: id, completion: completion)
    }
}