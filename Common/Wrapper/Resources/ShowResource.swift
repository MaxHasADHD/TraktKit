//
//  ShowResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    /// Endpoints for shows in general
    public struct ShowsResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        /**
         Returns all shows being watched right now. Shows with the most users are returned first.
         */
        public func trending() -> Route<PagedObject<[TraktTrendingShow]>> {
            Route(path: "shows/trending", method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most popular shows. Popularity is calculated using the rating percentage and the number of ratings.
         */
        public func popular() -> Route<PagedObject<[TraktShow]>> {
            Route(path: "shows/popular", method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most favorited shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func favorited(period: Period? = nil) -> Route<PagedObject<[TraktFavoritedShow]>> {
            Route(paths: ["shows/favorited", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most played (a single user can watch multiple episodes multiple times) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func played(period: Period? = nil) -> Route<PagedObject<[TraktMostShow]>> {
            Route(paths: ["shows/played", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most watched (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func watched(period: Period? = nil) -> Route<PagedObject<[TraktMostShow]>> {
            Route(paths: ["shows/watched", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most collected (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
         */
        public func collected(period: Period? = nil) -> Route<PagedObject<[TraktMostShow]>> {
            Route(paths: ["shows/collected", period], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most anticipated shows based on the number of lists a show appears on.
         */
        public func anticipated() -> Route<PagedObject<[TraktAnticipatedShow]>> {
            Route(path: "shows/anticipated", method: .GET, traktManager: traktManager)
        }

        /**
         Returns all shows updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.

         📄 Pagination

         > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

         > note: .The `startDate` can only be a maximum of 30 days in the past.
         */
        public func recentlyUpdated(since startDate: Date) async throws -> Route<PagedObject<[Update]>> {
            let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            return Route(path: "shows/updates/\(formattedDate)", method: .GET, traktManager: traktManager)
        }

        /**
         Returns all show Trakt IDs updated since the specified UTC date and time. We recommended storing the X-Start-Date header you can be efficient using this method moving forward. By default, 10 results are returned. You can send a limit to get up to 100 results per page.

         📄 Pagination

         > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

         > note: .The `startDate` can only be a maximum of 30 days in the past.
         */
        public func recentlyUpdatedIds(since startDate: Date) async throws -> Route<PagedObject<[Int]>> {
            let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            return Route(path: "shows/updates/id/\(formattedDate)", method: .GET, traktManager: traktManager)
        }
    }

    /// Endpoints for a specific series
    public struct ShowResource {

        // MARK: - Properties

        /// Trakt ID, Trakt slug, or IMDB ID
        internal let id: CustomStringConvertible
        internal let path: String

        private let traktManager: TraktManager

        // MARK: - Lifecycle

        internal init(id: CustomStringConvertible, traktManager: TraktManager) {
            self.id = id
            self.traktManager = traktManager
            self.path = "movies/\(id)"
        }

        // MARK: - Methods

        /**
         Returns a single shows's details. If you request extended info, the `airs` object is relative to the show's country. You can use the `day`, `time`, and `timezone` to construct your own date then convert it to whatever timezone your user is in.
         */
        public func summary() -> Route<TraktShow> {
            Route(path: path, method: .GET, traktManager: traktManager)
        }

        /**
         Returns all title aliases for a show. Includes country where name is different.
         */
        public func aliases() -> Route<[Alias]> {
            Route(paths: [path, "aliases"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all content certifications for a show, including the country.
         */
        public func certifications() -> Route<Certifications> {
            Route(paths: [path, "certifications"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all translations for a show, including language and translated values for title and overview.

         - parameter language: 2 character language code Example: `es`
         */
        public func translations(language: String? = nil) -> Route<[TraktShowTranslation]> {
            Route(paths: [path, "translations", language], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all top level comments for a show. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, most `replies`, `highest` rated, `lowest` rated, most `plays`, and highest `watched` percentage.

         🔓 OAuth Optional 📄 Pagination 😁 Emojis

         > note: If you send OAuth, comments from blocked users will be automatically filtered out.

         - parameter sort: how to sort Example: `newest`.
         - parameter authenticate: comments from blocked users will be automatically filtered out if `true`.
         */
        public func comments(sort: String? = nil, authenticate: Bool = false) -> Route<PagedObject<[Comment]>> {
            Route(paths: [path, "comments", sort], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        /**
         Returns all lists that contain this show. By default, `personal` lists are returned sorted by the most `popular`.

         📄 Pagination 😁 Emojis

         - parameter type: Filter for a specific list type. Possible values:  `all` , `personal` , `official` , `watchlists` , `favorites` .
         - parameter sort: How to sort . Possible values:  `popular` , `likes` , `comments` , `items` , `added` , `updated` .
         */
        public func containingLists(type: String? = nil, sort: String? = nil) -> Route<PagedObject<[TraktList]>> {
            Route(paths: [path, "lists", type, sort], method: .GET, traktManager: traktManager)
        }

        // MARK: - Progress

        /**
         Returns collection progress for a show including details on all aired seasons and episodes. The `next_episode` will be the next episode the user should collect, if there are no upcoming episodes it will be set to `null`.

         By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.

         By default, specials will be excluded from the response. Set the `specials` flag to `true` to include season 0 and adjust the stats accordingly. If you'd like to include specials, but not adjust the stats, set `count_specials` to `false`.

         By default, the `last_episode` and `next_episode` are calculated using the last `aired` episode the user has collected, even if they've collected older episodes more recently. To use their last collected episode for these calculations, set the `last_activity` flag to `collected`.

         > note: Only aired episodes are used to calculate progress. Episodes in the future or without an air date are ignored.

         🔒 OAuth Required

         - parameter includeHiddenSeasons: Include any hidden seasons
         - parameter includeSpecials: Include specials as season 0
         - parameter progressCountsSpecials: Count specials in the overall stats (only applies if specials are included)
         */
        public func collectedProgress(includeHiddenSeasons: Bool? = nil, includeSpecials: Bool? = nil, progressCountsSpecials: Bool? = nil) -> Route<ShowCollectionProgress> {
            Route(
                paths: [path, "progress/collection"],
                queryItems: [
                    "hidden": includeHiddenSeasons?.description,
                    "specials": includeSpecials?.description,
                    "count_specials": progressCountsSpecials?.description
                ].compactMapValues { $0 },
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Returns watched progress for a show including details on all aired seasons and episodes. The `next_episode` will be the next episode the user should watch, if there are no upcoming episodes it will be set to `null`. If not `null`, the `reset_at` date is when the user started re-watching the show. Your app can adjust the progress by ignoring episodes with a `last_watched_at` prior to the `reset_at`.

         By default, any hidden seasons will be removed from the response and stats. To include these and adjust the completion stats, set the `hidden` flag to `true`.

         By default, specials will be excluded from the response. Set the `specials` flag to `true` to include season 0 and adjust the stats accordingly. If you'd like to include specials, but not adjust the stats, set `count_specials` to `false`.

         By default, the `last_episode` and `next_episode` are calculated using the last `aired` episode the user has watched, even if they've watched older episodes more recently. To use their last watched episode for these calculations, set the `last_activity` flag to watched.

         > note: Only aired episodes are used to calculate progress. Episodes in the future or without an air date are ignored.

         🔒 OAuth Required

         - parameter includeHiddenSeasons: Include any hidden seasons
         - parameter includeSpecials: Include specials as season 0
         - parameter progressCountsSpecials: Count specials in the overall stats (only applies if specials are included)
         */
        public func watchedProgress(includeHiddenSeasons: Bool? = nil, includeSpecials: Bool? = nil, progressCountsSpecials: Bool? = nil) -> Route<TraktShowWatchedProgress> {
            Route(
                paths: [path, "progress/watched"],
                queryItems: [
                    "hidden": includeHiddenSeasons?.description,
                    "specials": includeSpecials?.description,
                    "count_specials": progressCountsSpecials?.description
                ].compactMapValues { $0 },
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        // MARK: Reset - VIP

        // MARK: -

        /**
         Returns all `cast` and `crew` for a show. Each `cast` member will have a `characters` array and a standard `person` object.The `crew` object will be broken up by department into production, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, and `editing` (if there are people for those crew positions). Each of those members will have a `jobs` array and a standard `person` object.

         **Guest Stars**

         If you add `?extended=guest_stars` to the URL, it will return all guest stars that appeared in at least 1 episode of the show.

         > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

         ✨ Extended Info
         */
        public func people() -> Route<CastAndCrew<TVCastMember, TVCrewMember>> {
            Route(paths: [path, "people"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns rating (between 0 and 10) and distribution for a show.
         */
        public func ratings() -> Route<RatingDistribution> {
            Route(paths: [path, "ratings"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns related and similar shows.

         📄 Pagination ✨ Extended Info
         */
        public func relatedShows() -> Route<PagedObject<[TraktShow]>> {
            Route(paths: [path, "related"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns lots of show stats.
         */
        public func stats() -> Route<TraktStats> {
            Route(paths: [path, "stats"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all studios for a show.
         */
        public func studios() -> Route<[TraktStudio]> {
            Route(paths: [path, "studios"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all users watching this show right now.

         ✨ Extended Info
         */
        public func usersWatching() -> Route<[User]> {
            Route(paths: [path, "watching"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the next scheduled to air episode. If no episode is found, a `204` HTTP status code will be returned.

         ✨ Extended Info
         */
        public func nextEpisode() -> Route<TraktEpisode> {
            Route(paths: [path, "next_episode"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns the most recently aired episode. If no episode is found, a `204` HTTP status code will be returned.

         ✨ Extended Info
         */
        public func lastEpisode() -> Route<TraktEpisode> {
            Route(paths: [path, "last_episode"], method: .GET, traktManager: traktManager)
        }

        /**
         Returns all videos including trailers, teasers, clips, and featurettes.

         ✨ Extended Info
         */
        public func videos() -> Route<[TraktVideo]> {
            Route(paths: [path, "videos"], method: .GET, traktManager: traktManager)
        }

        /**
         Queue this show for a full metadata and image refresh. It might take up to 8 hours for the updated metadata to be availabe through the API.

         > note: If this show is already queued, a `409` HTTP status code will returned.

         🔥 VIP Only 🔒 OAuth Required
         */
        public func refreshMetadata() -> EmptyRoute {
            EmptyRoute(paths: [path, "refresh"], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Returns all seasons for a show including the number of episodes in each season.

         **Episodes**

         If you add `?extended=episodes` to the URL, it will return all episodes for all seasons.

         > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

         ✨ Extended Info
         */
        public func seasons() -> Route<[TraktSeason]> {
            Route(paths: [path, "seasons"], method: .GET, traktManager: traktManager)
        }

        // MARK: - Resources

        public func season(_ number: Int) -> SeasonResource {
            SeasonResource(showId: id, seasonNumber: number, traktManager: traktManager)
        }
    }

}
