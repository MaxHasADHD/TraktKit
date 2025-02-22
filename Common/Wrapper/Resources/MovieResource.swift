//
//  MovieResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    /// Endpoints for movies in general
    public struct MoviesResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        /**
         Returns all movies being watched right now. Movies with the most users are returned first.
         */
        public func trending() -> Route<PagedObject<[TraktTrendingMovie]>> {
            Route(path: "movies/trending", method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most popular movies. Popularity is calculated using the rating percentage and the number of ratings.
         */
        public func popular() -> Route<PagedObject<[TraktMovie]>> {
            Route(path: "movies/popular", method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most favorited movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func favorited(period: Period? = nil) -> Route<PagedObject<[TraktFavoritedMovie]>> {
            Route(paths: ["movies/favorited", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most played (a single user can watch multiple times) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func played(period: Period? = nil) -> Route<PagedObject<[TraktMostMovie]>> {
            Route(paths: ["movies/played", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most watched (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func watched(period: Period? = nil) -> Route<PagedObject<[TraktMostMovie]>> {
            Route(paths: ["movies/watched", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most collected (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func collected(period: Period? = nil) -> Route<PagedObject<[TraktMostMovie]>> {
            Route(paths: ["movies/collected", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most anticipated movies based on the number of lists a movie appears on.
         */
        public func anticipated() -> Route<PagedObject<[TraktAnticipatedMovie]>> {
            Route(path: "movies/anticipated", method: .GET, traktManager: traktManager)
        }

        /**
         Returns the top 10 grossing movies in the U.S. box office last weekend. Updated every Monday morning.
         */
        public func boxOffice() -> Route<[TraktBoxOfficeMovie]> {
            Route(path: "movies/boxoffice", method: .GET, traktManager: traktManager)
        }

        /**
         Returns all movies updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.

         📄 Pagination

         > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

         > note: .The `startDate` can only be a maximum of 30 days in the past.
         */
        public func recentlyUpdated(since startDate: Date) async throws -> Route<PagedObject<[Update]>> {
            let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            return Route(path: "movies/updates/\(formattedDate)", method: .GET, traktManager: traktManager)
        }

        /**
         Returns all movie Trakt IDs updated since the specified UTC date and time. We recommended storing the X-Start-Date header you can be efficient using this method moving forward. By default, 10 results are returned. You can send a limit to get up to 100 results per page.

         📄 Pagination

         > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

         > note: .The `startDate` can only be a maximum of 30 days in the past.
         */
        public func recentlyUpdatedIds(since startDate: Date) async throws -> Route<PagedObject<[Int]>> {
            let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            return Route(path: "movies/updates/id/\(formattedDate)", method: .GET, traktManager: traktManager)
        }
    }

    /// Endpoints for a specific movie
    public struct MovieResource {
        // MARK: - Properties

        /// Trakt ID, Trakt slug, or IMDB ID
        internal let id: String
        internal let path: String

        private let traktManager: TraktManager

        // MARK: - Lifecycle

        internal init(id: CustomStringConvertible, traktManager: TraktManager) {
            self.id = id.description
            self.traktManager = traktManager
            self.path = "movies/\(id)"
        }

        // MARK: - Methods

        /**
         Returns a single movie's details.

         > note: When getting `full` extended info, the `status` field can have a value of `released`, `in production`, `post production`, `planned`, `rumored`, or `canceled`.
         */
        public func summary() -> Route<TraktMovie> {
            Route(path: path, method: .GET, traktManager: traktManager)
        }

        /**
         Returns all title aliases for a movie. Includes country where name is different.
         */
        public func aliases() -> Route<[Alias]> {
            Route(paths: [path, "aliases"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all releases for a movie including country, certification, release date, release type, and note. The release type can be set to unknown, premiere, limited, theatrical, digital, physical, or tv. The note might have optional info such as the film festival name for a premiere release or Blu-ray specs for a physical release. We pull this info from TMDB.'

         - parameter country: 2 character country code Example: `us`
         */
        public func releases(country: String? = nil) -> Route<[TraktMovieRelease]> {
            Route(paths: [path, "releases", country], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all translations for a movie, including language and translated values for title, tagline and overview.

         - parameter language: 2 character language code Example: `es`
         */
        public func translations(language: String? = nil) -> Route<[TraktMovieTranslation]> {
            Route(paths: [path, "translations", language], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all top level comments for a movie. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, most `replies`, `highest` rated, `lowest` rated, most `plays`, and highest `watched` percentage.

         🔓 OAuth Optional 📄 Pagination 😁 Emojis

         > note: If you send OAuth, comments from blocked users will be automatically filtered out.

         - parameter sort: how to sort Example: `newest`.
         - parameter authenticate: comments from blocked users will be automatically filtered out if `true`.
         */
        public func comments(sort: String? = nil, authenticate: Bool = false) -> Route<PagedObject<[Comment]>> {
            Route(paths: [path, "comments", sort], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        /**
         Returns all lists that contain this movie. By default, `personal` lists are returned sorted by the most `popular`.

         📄 Pagination 😁 Emojis

         - parameter type: Filter for a specific list type. Possible values:  `all` , `personal` , `official` , `watchlists` , `favorites` .
         - parameter sort: How to sort . Possible values:  `popular` , `likes` , `comments` , `items` , `added` , `updated` .
         */
        public func containingLists(type: String? = nil, sort: String? = nil) -> Route<PagedObject<[TraktList]>> {
            Route(paths: [path, "lists", type, sort], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all `cast` and `crew` for a movie. Each `cast` member will have a `characters` array and a standard `person` object.The `crew` object will be broken up by department into production, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, and `editing` (if there are people for those crew positions). Each of those members will have a `jobs` array and a standard `person` object.

         ✨ Extended Info
         */
        public func people() -> Route<CastAndCrew<MovieCastMember, MovieCrewMember>> {
            Route(paths: [path, "people"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns rating (between 0 and 10) and distribution for a movie.
         */
        public func ratings() -> Route<RatingDistribution> {
            Route(paths: [path, "ratings"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns related and similar movies.

         📄 Pagination ✨ Extended Info
         */
        public func relatedMovies() -> Route<PagedObject<[TraktMovie]>> {
            Route(paths: [path, "related"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns lots of movie stats.
         */
        public func stats() -> Route<TraktMovieStats> {
            Route(paths: [path, "stats"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all studios for a movie.
         */
        public func studios() -> Route<[TraktStudio]> {
            Route(paths: [path, "studios"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all users watching this movie right now.

         ✨ Extended Info
         */
        public func usersWatching() -> Route<[User]> {
            Route(paths: [path, "watching"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all videos including trailers, teasers, clips, and featurettes.

         ✨ Extended Info
         */
        public func videos() -> Route<[TraktVideo]> {
            Route(paths: [path, "videos"], method: .GET, traktManager: traktManager)
        }

        /**
         Queue this movie for a full metadata and image refresh. It might take up to 8 hours for the updated metadata to be availabe through the API.

         > note: If this movie is already queued, a 409 HTTP status code will returned.

         🔥 VIP Only 🔒 OAuth Required
         */
        public func refreshMetadata() -> EmptyRoute {
            EmptyRoute(paths: [path, "refresh"], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }
    }
}
