//
//  PeopleResource.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/18/26.
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /// Endpoints for people in general (not specific to a single person).
    public struct PeopleResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Updates

        /**
         Returns all people updated since the specified UTC date and time. We recommended storing the `X-Start-Date` header so you can be efficient using this method moving forward. By default, `10` results are returned. You can send a `limit` to get up to `100` results per page.

         **Endpoint:** `GET /people/updates/{start_date}`

         📄 Pagination • ✨ Extended Info

         > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`.

         > note: The `startDate` can only be a maximum of 30 days in the past.

         - parameter startDate: Returns people updated since this UTC date and time.
         */
        public func recentlyUpdated(since startDate: Date) -> Route<PagedObject<[PersonUpdate]>> {
            let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            return Route(path: "people/updates/\(formattedDate)", method: .GET, traktManager: traktManager)
        }

        /**
         Returns all people Trakt IDs updated since the specified UTC date and time. We recommended storing the `X-Start-Date` header so you can be efficient using this method moving forward. By default, `10` results are returned. You can send a `limit` to get up to `100` results per page.

         **Endpoint:** `GET /people/updates/id/{start_date}`

         📄 Pagination

         > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`.

         > note: The `startDate` can only be a maximum of 30 days in the past.

         - parameter startDate: Returns people Trakt IDs updated since this UTC date and time.
         */
        public func recentlyUpdatedIds(since startDate: Date) -> Route<PagedObject<[Int]>> {
            let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            return Route(path: "people/updates/id/\(formattedDate)", method: .GET, traktManager: traktManager)
        }
    }

    /// Endpoints for a specific person
    public struct PersonResource {

        // MARK: - Properties

        /// Trakt ID, Trakt slug, or IMDB ID
        public let id: CustomStringConvertible
        private let path: String
        private let traktManager: TraktManager

        // MARK: - Lifecycle

        internal init(id: CustomStringConvertible, traktManager: TraktManager) {
            self.id = id
            self.traktManager = traktManager
            self.path = "people/\(id)"
        }

        // MARK: - Methods

        /**
         Returns a single person's details.

         #### Gender
         If available, the `gender` property will be set to `male`, `female`, or `non_binary`.

         #### Known For Department
         If available, the `known_for_department` property will be set to `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, or `editing`. Many people have credits across departments, `known_for` allows you to select their default credits more accurately.

         **Endpoint:** `GET /people/{id}`

         ✨ Extended Info
         */
        public func details() -> Route<Person> {
            Route(paths: [path], method: .GET, traktManager: traktManager)
        }

        // MARK: - Movies

        /**
         Returns all movies where this person is in the `cast` or `crew`. Each `cast` object will have a `characters` array and a standard `movie` object.

         The `crew` object will be broken up by department into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, and `editing` (if there are people for those crew positions). Each of those members will have a `jobs` array and a standard `movie` object.

         **Endpoint:** `GET /people/{id}/movies`

         ✨ Extended Info
         */
        public func movieCredits() -> Route<CastAndCrew<PeopleMovieCastMember, PeopleMovieCrewMember>> {
            Route(paths: [path, "movies"], method: .GET, traktManager: traktManager)
        }

        // MARK: - Shows

        /**
         Returns all shows where this person is in the `cast` or `crew`, including the `episode_count` for which they appear. Each `cast` object will have a `characters` array and a standard `show` object. If `series_regular` is `true`, this person is a series regular and not simply a guest star.

         The `crew` object will be broken up by department into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, `editing`, and `created by` (if there are people for those crew positions). Each of those members will have a `jobs` array and a standard `show` object.

         **Endpoint:** `GET /people/{id}/shows`

         ✨ Extended Info
         */
        public func showCredits() -> Route<CastAndCrew<PeopleTVCastMember, PeopleTVCrewMember>> {
            Route(paths: [path, "shows"], method: .GET, traktManager: traktManager)
        }

        // MARK: - Lists

        /**
         Returns all lists that contain this person. By default, `personal` lists are returned sorted by the most `popular`.

         **Endpoint:** `GET /people/{id}/lists/{type}/{sort}`

         📄 Pagination • 😁 Emojis

         - parameter type: Filter for a specific list type. Possible values: `all`, `personal`, `official`.
         - parameter sort: How to sort. Possible values: `popular`, `likes`, `comments`, `items`, `added`, `updated`.
         */
        public func containingLists(type: String? = nil, sort: String? = nil) -> Route<PagedObject<[TraktList]>> {
            Route(paths: [path, "lists", type, sort], method: .GET, traktManager: traktManager)
        }

        // MARK: - Refresh

        /**
         Queue this person for a full metadata and image refresh. It might take up to 8 hours for the updated metadata to be available through the API.

         > note: If this person is already queued, a `409` HTTP status code will be returned.

         **Endpoint:** `POST /people/{id}/refresh`

         🔥 VIP Only • 🔒 OAuth Required
         */
        public func refresh() -> EmptyRoute {
            EmptyRoute(paths: [path, "refresh"], method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }
    }
}
