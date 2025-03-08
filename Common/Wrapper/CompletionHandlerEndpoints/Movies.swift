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
    @discardableResult
    public func getTrendingMovies(pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping TrendingMoviesCompletionHandler) -> URLSessionDataTask? {
        return getTrending(.Movies, pagination: pagination, extended: extended, filters: filters, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
    Returns the most popular movies. Popularity is calculated using the rating percentage and the number of ratings.
    
    📄 Pagination
    */
    @discardableResult
    public func getPopularMovies(pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], filters: [Filter]? = nil, completion: @escaping paginatedCompletionHandler<TraktMovie>) -> URLSessionDataTask? {
        return getPopular(.Movies, pagination: pagination, extended: extended, filters: filters, completion: completion)
    }
    
    // MARK: - Played
    
    /**
    Returns the most played (a single user can watch multiple times) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    @discardableResult
    public func getPlayedMovies(period: Period = .weekly, pagination: Pagination? = nil, completion: @escaping MostMoviesCompletionHandler) -> URLSessionDataTask? {
        return getPlayed(.Movies, period: period, pagination: pagination, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
    Returns the most watched (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    @discardableResult
    public func getWatchedMovies(period: Period = .weekly, pagination: Pagination? = nil, completion: @escaping MostMoviesCompletionHandler) -> URLSessionDataTask? {
        return getWatched(.Movies, period: period, pagination: pagination, completion: completion)
    }
    
    // MARK: - Collected
    
    /**
    Returns the most collected (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    @discardableResult
    public func getCollectedMovies(period: Period = .weekly, pagination: Pagination? = nil, completion: @escaping MostMoviesCompletionHandler) -> URLSessionDataTask? {
        return getCollected(.Movies, period: period, pagination: pagination, completion: completion)
    }
    
    // MARK: - Anticipated
    
    /**
    Returns the most anticipated movies based on the number of lists a movie appears on.
    
    📄 Pagination
    */
    @discardableResult
    public func getAnticipatedMovies(pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], completion: @escaping AnticipatedMovieCompletionHandler) -> URLSessionDataTask? {
        return getAnticipated(.Movies, pagination: pagination, extended: extended, completion: completion)
    }
    
    // MARK: - Box Office
    
    /**
    Returns the top 10 grossing movies in the U.S. box office last weekend. Updated every Monday morning.
    */
    @discardableResult
    public func getWeekendBoxOffice(extended: [ExtendedType] = [.Min], completion: @escaping BoxOfficeMoviesCompletionHandler) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "movies/boxoffice",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Updates
    
    /**
    Returns all movies updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.
    
    📄 Pagination
    */
    @discardableResult
    public func getUpdatedMovies(startDate: Date?, pagination: Pagination? = nil, extended: [ExtendedType] = [.Min], completion: @escaping paginatedCompletionHandler<Update>) -> URLSessionDataTask? {
        return getUpdated(.Movies, startDate: startDate, pagination: pagination, extended: extended, completion: completion)
    }
    
    // MARK: - Summary
    
    /**
    Returns a single movie's details.
    */
    @discardableResult
    public func getMovieSummary<T: CustomStringConvertible>(movieID id: T, extended: [ExtendedType] = [.Min], completion: @escaping MovieCompletionHandler) -> URLSessionDataTask? {
        return getSummary(.Movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Aliases
    
    /**
    Returns all title aliases for a movie. Includes country where name is different.
    */
    @discardableResult
    public func getMovieAliases<T: CustomStringConvertible>(movieID id: T, completion: @escaping ObjectCompletionHandler<[Alias]>) -> URLSessionDataTask? {
        return getAliases(.Movies, id: id, completion: completion)
    }
    
    // MARK: - Releases
    
    /**
    Returns all releases for a movie including country, certification, and release date.
    
    - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
    - parameter country: 2 character country code. Example: `us`.
    */
    @discardableResult
    public func getMovieReleases<T: CustomStringConvertible>(movieID id: T, country: String?, completion: @escaping ObjectCompletionHandler<[TraktMovieRelease]>) -> URLSessionDataTask? {
        
        var path = "movies/\(id)/releases"
        
        if let country = country {
            path += "/\(country)"
        }
        
        guard let request = try? mutableRequest(forPath: path,
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Translations
    
    /**
    Returns all translations for a movie, including language and translated values for title, tagline and overview.
    */
    @discardableResult
    public func getMovieTranslations<T: CustomStringConvertible>(movieID id: T, language: String?, completion: @escaping MovieTranslationsCompletionHandler) -> URLSessionDataTask? {
        return getTranslations(.Movies, id: id, language: language, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
    Returns all top level comments for a movie. Most recent comments returned first.
    
    📄 Pagination
    */
    @discardableResult
    public func getMovieComments<T: CustomStringConvertible>(movieID id: T, pagination: Pagination? = nil, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        return getComments(.Movies, id: id, pagination: pagination, completion: completion)
    }

    // MARK: - Lists

    /**
     Returns all lists that contain this movie. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    @discardableResult
    public func getListsContainingMovie<T: CustomStringConvertible>(movieID id: T,
                                                                    listType: ListType? = nil,
                                                                    sortBy: ListSortType? = nil,
                                                                    pagination: Pagination? = nil,
                                                                    completion: @escaping paginatedCompletionHandler<TraktList>) -> URLSessionDataTask? {
        var path = "movies/\(id)/lists"
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

    // MARK: - People
    
    /**
    Returns all `cast` and `crew` for a movie. Each `cast` member will have a `character` and a standard `person` object.
    
    The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `person` object.
    */
    @discardableResult
    public func getPeopleInMovie<T: CustomStringConvertible>(movieID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<CastAndCrew<MovieCastMember, MovieCrewMember>>) -> URLSessionDataTask? {
        return getPeople(.Movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
    Returns rating (between 0 and 10) and distribution for a movie.
    */
    @discardableResult
    public func getMovieRatings<T: CustomStringConvertible>(movieID id: T, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTask? {
        return getRatings(.Movies, id: id, completion: completion)
    }
    
    // MARK: - Related
    
    /**
    Returns related and similar movies. By default, 10 related movies will returned. You can send a `limit` to get up to `100` items.
    
    **Note**: We are continuing to improve this algorithm.
    */
    @discardableResult
    public func getRelatedMovies<T: CustomStringConvertible>(movieID id: T, extended: [ExtendedType] = [.Min], completion: @escaping MoviesCompletionHandler) -> URLSessionDataTask? {
        return getRelated(.Movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
    Returns lots of movie stats.
    */
    @discardableResult
    public func getMovieStatistics<T: CustomStringConvertible>(movieID id: T, completion: @escaping statsCompletionHandler) -> URLSessionDataTask? {
        return getStatistics(.Movies, id: id, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
    Returns all users watching this movie right now.
    */
    @discardableResult
    public func getUsersWatchingMovie<T: CustomStringConvertible>(movieID id: T, completion: @escaping ObjectCompletionHandler<[User]>) -> URLSessionDataTask? {
        return getUsersWatching(.Movies, id: id, completion: completion)
    }
}
