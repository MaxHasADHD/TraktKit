//
//  SyncResource.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/1/25.
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /**
     Syncing with trakt opens up quite a few cool features. Most importantly, trakt can serve as a cloud based backup for the data in your app. This is especially useful when rebuilding a media center or installing a mobile app on your new phone. It can also be nice to sync up multiple media centers with a central trakt account. If everything is in sync, your media can be managed from trakt and be reflected in your apps.

     **Media objects for syncing**

     As a baseline, all add and remove sync methods accept arrays of `movies`, `shows`, and `episodes`. Each of these top level array elements should themselves be an array of standard `movie`, `show`, or `episode` objects. Full examples are in the intro section called **Standard Media Objects**. Keep in mind that `episode` objects really only need the `ids` so it can find an exact match. This is useful for absolute ordered shows. Some methods also have optional metadata you can attach, so check the docs for each specific method.

     Media objects will be matched by ID first, then fall back to title and year. IDs will be matched in this order `trakt`, `imdb`, `tmdb`, `tvdb`, and `slug`. If nothing is found, it will match on the `title` and `year`. If still nothing, it would use just the `title` (or `name` for people) and find the most current object that exists.

     ---
     **Watched History Sync**

     This is a 2 way sync that will get items from trakt to sync locally, plus find anything new and sync back to trakt. Perform this sync on startup or at set intervals (i.e. once every day) to keep everything in sync. This will only send data to trakt and not remove it.

     ---
     **Collection Sync**

     It's very handy to have a snapshot on trakt of everything you have available to watch locally. Syncing your local connection will do just that. This will only send data to trakt and not remove it.

     ---
     **Clean Collection**

     Cleaning a collection involves comparing the trakt collection to what exists locally. This will remove items from the trakt collection if they don't exist locally anymore. You should make this clear to the user that data might be removed from trakt.
     */
    public struct SyncResource {

        private let path = "sync"
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Routes

        /**
         This method is a useful first step in the syncing process. We recommended caching these dates locally, then you can compare to know exactly what data has changed recently. This can greatly optimize your syncs so you don't pull down a ton of data only to see nothing has actually changed.

         **Account**

         `settings_at` is set when the OAuth user updates any of their Trakt settings on the website. `followed_at` is set when another Trakt user follows or unfollows the OAuth user. `following_at` is set when the OAuth user follows or unfollows another Trakt user. `pending_at` is set when the OAuth user follows a private account, which requires their approval. `requested_at` is set when the OAuth user has a private account and someone requests to follow them.

         🔒 OAuth Required
         */
        public func lastActivities() -> Route<TraktLastActivities> {
            Route(paths: [path, "last_activities"], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: - Playback

        public func playback(type: String) -> Route<[PlaybackProgress]> {
            Route(paths: [path, "playback", type], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Remove a playback item from a user's playback progress list. A `404` will be returned if the `id` is invalid.
         */
        public func removePlayback(id: CustomStringConvertible) -> EmptyRoute {
            EmptyRoute(paths: [path, "playback", id], method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: - Collections

        /**
         Get all collected items in a user's collection. A collected item indicates availability to watch digitally or on physical media.

         Each `movie` object contains `collected_at` and `updated_at` timestamps. Since users can set custom dates when they collected movies, it is possible for `collected_at` to be in the past. We also include `updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the movie if you see a newer timestamp.

         Each `show` object contains `last_collected_at` and `last_updated_at` timestamps. Since users can set custom dates when they collected episodes, it is possible for `last_collected_at` to be in the past. We also include `last_updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the show if you see a newer timestamp.

         If you add `?extended=metadata` to the URL, it will return the additional `media_type`, `resolution`, `hdr`, `audio`, `audio_channels` and `3d` metadata. It will use `null` if the metadata isn't set for an item.

         🔒 OAuth Required ✨ Extended Info

         - parameter type: Possible values:  `movies` , `shows` .
         */
        public func collection(type: String) -> Route<[TraktCollectedItem]> {
            Route(paths: [path, "collection", type], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Add items to a user's collection. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be collected. If seasons are specified, all episodes in those seasons will be collected.

         Send a `collected_at` UTC datetime to mark items as collected in the past. You can also send additional metadata about the media itself to have a very accurate collection. Showcase what is available to watch from your epic HD DVD collection down to your downloaded iTunes movies.

         **Limits**

         If the user's collection limit is exceeded, a `420` HTTP error code is returned. Use the `/users/settings` method to get all limits for a user account. In most cases, upgrading to Trakt VIP will increase the limits.

         > note: You can resend items already in your collection and they will be updated with any new values. This includes the `collected_at` and any other metadata.
         */
        public func addToCollection(movies: [CollectionId]? = nil, shows: [CollectionId]? = nil, seasons: [CollectionId]? = nil, episodes: [CollectionId]? = nil) -> Route<AddToCollectionResult> {
            Route(
                paths: [path, "collection"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Remove one or more items from a user's collection.

         - parameter movies: Array of movie Trakt ids
         - parameter shows: Array of show Trakt ids
         - parameter seasons: Array of season Trakt ids
         - parameter episodes: Array of episode Trakt ids

         🔒 OAuth Required
         */
        public func removeFromCollection(movies: [SyncId]? = nil, shows: [SyncId]? = nil, seasons: [SyncId]? = nil, episodes: [SyncId]? = nil) -> Route<RemoveFromCollectionResult> {
            Route(
                paths: [path, "collection", "remove"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        // MARK: - Watched

        /**
         Returns all movies or shows a user has watched sorted by most plays.

         If type is set to `shows` and you add `?extended=noseasons` to the URL, it won't return season or episode info.

         Each `movie` and `show` object contains `last_watched_at` and `last_updated_at` timestamps. Since users can set custom dates when they watched movies and episodes, it is possible for `last_watched_at` to be in the past. We also include `last_updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the movies and shows if you see a newer timestamp.

         Each show object contains a `reset_at` timestamp. If not `null`, this is when the user started re-watching the show. Your app can adjust the progress by ignoring episodes with a `last_watched_at` prior to the `reset_at`.

         🔒 OAuth Required ✨ Extended Info

         - parameter type: Possible values:  `movies` , `shows` .
         */
        private func watched<T: TraktObject>(type: String) -> Route<[T]> {
            Route(paths: [path, "watched", type], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Returns all shows a user has watched sorted by most plays.

         You add `?extended=noseasons` to the URL, it won't return season or episode info.

         Each `show` object contains `last_watched_at` and `last_updated_at` timestamps. Since users can set custom dates when they watched episodes, it is possible for `last_watched_at` to be in the past. We also include `last_updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the movies and shows if you see a newer timestamp.

         Each `show` object contains a `reset_at` timestamp. If not `null`, this is when the user started re-watching the show. Your app can adjust the progress by ignoring episodes with a `last_watched_at` prior to the `reset_at`.

         🔒 OAuth Required ✨ Extended Info
         */
        public func watchedShows() -> Route<[TraktWatchedShow]> {
            watched(type: "shows")
        }

        /**
         Returns all movies a user has watched sorted by most plays.

         Each `movie` object contains `last_watched_at` and `last_updated_at` timestamps. Since users can set custom dates when they watched movies, it is possible for `last_watched_at` to be in the past. We also include `last_updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the movies and shows if you see a newer timestamp.

         🔒 OAuth Required ✨ Extended Info
         */
        public func watchedMovies() -> Route<[TraktWatchedMovie]> {
            watched(type: "movies")
        }

        // MARK: - History

        /**
         Returns movies and episodes that a user has watched, sorted by most recent. You can optionally limit the `type` to `movies` or `episodes`. The `id` (64-bit integer) in each history item uniquely identifies the event and can be used to remove individual events by using the `/sync/history/remove` method. The `action` will be set to `scrobble`, `checkin`, or `watch`.

         Specify a `type` and trakt `id` to limit the history for just that item. If the `id` is valid, but there is no history, an empty array will be returned.

         🔒 OAuth Required 📄 Pagination ✨ Extended Info

         - Parameters:
            - type: Possible values:  `movies` , `shows` , `seasons` , `episodes`.
            - mediaId: Trakt ID for a specific item.
            - startingAt: Starting date.
            - endingAt: Ending date.
         */
        public func history(
            type: String? = nil,
            mediaId: CustomStringConvertible? = nil,
            startingAt: Date? = nil,
            endingAt: Date? = nil
        ) -> Route<PagedObject<[TraktHistoryItem]>> {
            Route(
                paths: [path, "history", type, mediaId],
                queryItems: [
                    "start_at": startingAt?.UTCDateString(),
                    "end_at": endingAt?.UTCDateString()
                ].compactMapValues { $0 },
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Add items to a user's watch history. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be added. If seasons are specified, only episodes in those seasons will be added.

         Send a `watched_at` UTC datetime to mark items as watched in the past. This is useful for syncing past watches from a media center.

         > important: Please be careful with sending duplicate data. We don't verify the `item` + `watched_at` to ensure it's unique, it is up to your app to veify this and not send duplicate plays.

         🔒 OAuth Required

         - parameters:
            - movies: array of `movie` objects
            -  shows: array of `show` objects
            -  seasons: array of `season` objects
            - episodes: array of `episode` objects
         */
        public func addToHistory(
            movies: [AddToHistoryId]? = nil,
            shows: [AddToHistoryId]? = nil,
            seasons: [AddToHistoryId]? = nil,
            episodes: [AddToHistoryId]? = nil
        ) -> Route<AddToHistoryResult> {
            Route(
                paths: [path, "history"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Remove items from a user's watch history including all watches, scrobbles, and checkins. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be removed. If seasons are specified, only episodes in those seasons will be removed.

         You can also send a list of raw history `ids` (64-bit integers) to delete single plays from the watched history. The ``TraktManager/SyncResource/history(type:mediaId:startingAt:endingAt:)`` method will return an individual `id` (64-bit integer) for each history item.

         🔒 OAuth Required
         */
        public func removeFromHistory(
            movies: [SyncId]? = nil,
            shows: [SyncId]? = nil,
            seasons: [SyncId]? = nil,
            episodes: [SyncId]? = nil,
            historyIDs: [Int]? = nil
        ) -> Route<RemoveFromHistoryResult> {
            Route(
                paths: [path, "history", "remove"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes, ids: historyIDs),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        // MARK: - Ratings

        /**
         Get a user's ratings filtered by `type`. You can optionally filter for a specific `rating` between 1 and 10. Send a comma separated string for `rating` if you need multiple ratings.

         🔒 OAuth Required 📄 Pagination Optional ✨ Extended Info
         */
        public func ratings(type: String? = nil, rating: CustomStringConvertible? = nil) -> Route<PagedObject<[TraktRating]>> {
            Route(
                paths: [path, "ratings", type, rating],
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Rate one or more items. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be rated. If seasons are specified, all of those seasons will be rated.

         Send a ``RatingId/ratedAt``  datetime to mark items as rated in the past. This is useful for syncing ratings from a media center.

         🔒 OAuth Required

         - parameters:
            - movies: Array of movie Trakt ids
            - shows: Array of show Trakt ids
            - seasons: Array of season Trakt ids
            - episodes: Array of episode Trakt ids
         */
        public func addRatings(
            movies: [RatingId]? = nil,
            shows: [RatingId]? = nil,
            seasons: [RatingId]? = nil,
            episodes: [RatingId]? = nil
        ) -> Route<AddRatingsResult> {
            Route(
                paths: [path, "ratings"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Remove ratings for one or more items.

         🔒 OAuth Required
         */
        public func removeRatings(
            movies: [SyncId]? = nil,
            shows: [SyncId]? = nil,
            seasons: [SyncId]? = nil,
            episodes: [SyncId]? = nil
        ) -> Route<RemoveRatingsResult> {
            Route(
                paths: [path, "ratings", "remove"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        // MARK: - Watchlist

        /**
         Returns all items in a user's watchlist filtered by type.

         > Important: The watchlist should not be used as a list of what the user is actively watching. Use a combination of the ``TraktManager/SyncResource/watchedShows()`` and ``TraktManager/ShowResource/watchedProgress(includeHiddenSeasons:includeSpecials:progressCountsSpecials:)`` methods to get what the user is actively watching.

         ---
         **Notes**

         Each watchlist item contains a `notes` field with text entered by the user.

         ---
         **Sorting Headers**

         By default, all list items are sorted by `rank` `asc`. We send `X-Applied-Sort-By` and `X-Applied-Sort-How` headers to indicate how the results are actually being sorted.

         We also send `X-Sort-By` and `X-Sort-How` headers which indicate the user's sort preference. Use these to custom sort the watchlist **in your app** for more advanced sort abilities we can't do in the API. Values for `X-Sort-By` include `rank`, `added`, `title`, `released`, `runtime`, `popularity`, `percentage`, and `votes`. Values for `X-Sort-How` include `asc` and `desc`.

         ---
         **Auto Removal**

         When an item is watched, it will be automatically removed from the watchlist. For shows and seasons, watching 1 episode will remove the entire show or season.

         🔒 OAuth Required 📄 Pagination Optional ✨ Extended Info 😁 Emojis

         - parameters:
            - type: Filter for a specific item type. Possible values:  `movies` , `shows` , `seasons` , `episodes` .
            - sort: How to sort (only if type is also sent). Possible values:  `rank` , `added` , `released` , `title` .
         */
        public func watchlist(type: String? = nil, sort: String? = nil) -> Route<PagedObject<[TraktListItem]>> {
            Route(
                paths: [path, "watchlist", type, sort],
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Update the watchlist by sending 1 or more parameters.

         🔒 OAuth Required
         */
        public func updateWatchlist(description: String? = nil, sortBy: String? = nil, sortHow: String? = nil) -> Route<TraktList> {
            Route(
                paths: [path, "watchlist"],
                body: WatchlistUpdate(description: description, sortBy: sortBy, sortHow: sortHow),
                method: .PUT,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Add one of more items to a user's watchlist. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be added. If seasons are specified, all of those seasons will be added.

         ---
         **Notes**

         Each watchlist item can optionally accept a `notes` (500 maximum characters) field with custom text. The user must be a Trakt VIP to send `notes`.

         ---
         **Limits**

         If the user's watchlist limit is exceeded, a `420` HTTP error code is returned. Use the ``TraktManager/CurrentUserResource/settings()`` method to get all limits for a user account. In most cases, upgrading to Trakt VIP will increase the limits.

         🔥 VIP Enhanced 🔒 OAuth Required 😁 Emojis

         - parameters:
            - movies: Array of movie Trakt ids
            - shows: Array of show Trakt ids
            - seasons: Array of season Trakt ids
            - episodes: Array of episode Trakt ids
         */
        public func addToWatchlist(movies: [SyncId]? = nil, shows: [SyncId]? = nil, seasons: [SyncId]? = nil, episodes: [SyncId]? = nil) -> Route<WatchlistItemPostResult> {
            Route(
                paths: [path, "watchlist"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Remove one or more items from a user's watchlist.

         🔒 OAuth Required

         - parameters:
            - movies: Array of movie Trakt ids
            - shows: Array of show Trakt ids
            - seasons: Array of season Trakt ids
            - episodes: Array of episode Trakt ids
         */
        public func removeFromWatchlist(movies: [SyncId]? = nil, shows: [SyncId]? = nil, seasons: [SyncId]? = nil, episodes: [SyncId]? = nil) -> Route<RemoveFromWatchlistResult> {
            Route(
                paths: [path, "watchlist", "remove"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        // MARK: - Favorites
    }
}
