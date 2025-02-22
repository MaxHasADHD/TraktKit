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

    public struct MovieResource {
        
    }
}
