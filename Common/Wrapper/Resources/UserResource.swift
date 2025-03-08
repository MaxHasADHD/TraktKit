//
//  UserResource.swift
//  
//
//  Created by Maximilian Litteral on 9/9/22.
//

import Foundation

extension TraktManager {
    /// Resource containing all of the `/user` endpoints that **require** authentication. These requests will always be for the current authenticated user, and cannot be performed for another user.
    public struct CurrentUserResource {

        static let currentUserSlug = "me"

        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Methods
        
        public func settings() -> Route<AccountSettings> {
            Route(path: "users/settings", method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: Following Requests

        /// List a user's pending following requests that they're waiting for the other user's to approve.
        public func getPendingFollowingRequests() -> Route<[FollowRequest]> {
            Route(path: "users/requests/following", method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /// List a user's pending follow requests so they can either approve or deny them.
        public func getFollowerRequests() -> Route<[FollowRequest]> {
            Route(path: "users/requests", method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Approve a follower using the id of the request. If the id is not found, was already approved, or was already denied, a 404 error will be returned.

         🔒 OAuth Required
         */
        public func approveFollowRequest(id: Int) -> Route<FollowResult> {
            Route(path: "users/requests/\(id)", method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Deny a follower using the id of the request. If the id is not found, was already approved, or was already denied, a 404 error will be returned.

         🔒 OAuth Required
         */
        public func denyFollowRequest(id: Int) -> EmptyRoute {
            EmptyRoute(path: "users/requests/\(id)", method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Get all saved filters a user has created. The path and query can be used to construct an API path to retrieve the saved data. Think of this like a dynamically updated list.

         🔥 VIP Only
         🔒 OAuth Required
         📄 Pagination
         */
        public func savedFilters(for section: String? = nil) -> Route<PagedObject<[SavedFilter]>> {
            Route(paths: ["users/saved_filters", section], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: - Hidden

        /**
         Get hidden items for a section. This will return an array of standard media objects. You can optionally limit the type of results to return.

         🔒 OAuth Required 📄 Pagination ✨ Extended Info
         */
        public func hiddenItems(for section: String, type: String? = nil) -> Route<PagedObject<[HiddenItem]>> {
            Route(
                paths: ["users/hidden", section],
                queryItems: ["type": type].compactMapValues { $0 },
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Hide items for a specific section. Here's what type of items can hidden for each section.

         🔒 OAuth Required
         */
        public func hide(movies: [SyncId] = [], shows: [SyncId] = [], seasons: [SyncId] = [], users: [SyncId] = [], in section: String) -> Route<HideItemResult> {
            Route(
                paths: ["users/hidden", section],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, users: users),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Unhide items for a specific section. Here's what type of items can unhidden for each section.

         🔒 OAuth Required
         */
        public func unhide(movies: [SyncId] = [], shows: [SyncId] = [], seasons: [SyncId] = [], users: [SyncId] = [], in section: String) -> Route<UnhideItemResult> {
            Route(
                paths: ["users/hidden", section, "remove"],
                body: TraktMediaBody(movies: movies, shows: shows, seasons: seasons, users: users),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Get a user's profile information. If the user is private, info will only be returned if you send OAuth and are either that user or an approved follower. Adding `?extended=vip` will return some additional VIP related fields so you can display the user's Trakt VIP status and year count.

         🔓 OAuth Required ✨ Extended Info
         */
        public func profile() -> Route<User> {
            UsersResource(slug: Self.currentUserSlug, traktManager: traktManager).profile()
        }
    }

    /// Resource containing all of the `/user/*` endpoints where authentication is **optional** or **not** required.
    public struct UsersResource {
        public let slug: String
        private let path: String
        private let authenticate: Bool
        private let traktManager: TraktManager

        internal init(slug: String, authenticate: Bool = false, traktManager: TraktManager) {
            self.slug = slug
            self.path = "users/\(slug)"
            self.authenticate = slug == "me" ? true : authenticate
            self.traktManager = traktManager
        }
        
        // MARK: - Methods

        /**
         Get a user's profile information. If the user is private, info will only be returned if you send OAuth and are either that user or an approved follower. Adding `?extended=vip` will return some additional VIP related fields so you can display the user's Trakt VIP status and year count.

         🔓 OAuth Optional ✨ Extended Info
         */
        public func profile() -> Route<User> {
            Route(paths: [path], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        // MARK: - Likes

        /**
         Get items a user likes. This will return an array of standard media objects. You can optionally limit the `type` of results to return.

         **Comment Media Objects**

         If you add `?extended=comments` to the URL, it will return media objects for each comment like.

         > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

         🔒 OAuth Optional 📄 Pagination
         */
        public func likes(type: String? = nil) -> Route<PagedObject<[Like]>> {
            Route(paths: [path, "likes", type], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        // MARK: - Collection

        /**
         Get all collected items in a user's collection. A collected item indicates availability to watch digitally or on physical media.

         Each `movie` object contains `collected_at` and `updated_at` timestamps. Since users can set custom dates when they collected movies, it is possible for `collected_at` to be in the past. We also include `updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the movie if you see a newer timestamp.

         Each show object contains `last_collected_at` and `last_updated_at` timestamps. Since users can set custom dates when they collected episodes, it is possible for `last_collected_at` to be in the past. We also include `last_updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the show if you see a newer timestamp.

         If you add `?extended=metadata` to the URL, it will return the additional `media_type`, `resolution`, `hdr`, `audio`, `audio_channels` and `3d` metadata. It will use `null` if the metadata isn't set for an item.

         🔓 OAuth Optional ✨ Extended Info

         - parameter type: `movies` or `shows`
         */
        public func collection(type: String) -> Route<[TraktCollectedItem]> {
            Route(paths: [path, "collection", type], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        // MARK: - Comments

        /**
         Returns the most recently written comments for the user. You can optionally filter by the `comment_type` and media `type` to limit what gets returned.

         By default, only top level comments are returned. Set `?include_replies=true` to return replies in addition to top level comments. Set `?include_replies=only` to return only replies and no top level comments.

         🔓 OAuth Optional 📄 Pagination ✨ Extended Info
         */
        public func comments(commentType: String? = nil, mediaType: String? = nil, includeReplies: String? = nil) -> Route<PagedObject<[UsersComments]>> {
            Route(
                paths: [path, "comments", commentType, mediaType],
                queryItems: ["include_replies": includeReplies].compactMapValues { $0 },
                method: .GET,
                requiresAuthentication: authenticate,
                traktManager: traktManager
            )
        }

        // MARK: - Notes

        // MARK: - Lists

        // MARK: - Collaborations

        // MARK: - List

        public func lists() -> Route<[TraktList]> {
            Route(paths: [path, "lists"], method: .GET, traktManager: traktManager)
        }

        public func itemsOnList(_ listId: String, type: ListItemType? = nil) -> Route<[TraktListItem]> {
            Route(paths: ["users/\(slug)/lists/\(listId)/items", type?.rawValue], method: .GET, traktManager: traktManager)
        }

        // MARK: - Follow

        // MARK: - Followers

        // MARK: - Following

        // MARK: - Friends

        // MARK: - History

        /**
         Returns movies and episodes that a user has watched, sorted by most recent. You can optionally limit the `type` to `movies` or `episodes`. The `id` (64-bit integer) in each history item uniquely identifies the event and can be used to remove individual events by using the `/sync/history/remove` method. The `action` will be set to `scrobble`, `checkin`, or `watch`.

         Specify a `type` and trakt `item_id` to limit the history for just that item. If the `item_id` is valid, but there is no history, an empty array will be returned.

         - parameters:
            - type: Possible values:  `movies` , `shows` , `seasons` , `episodes`.
            - mediaId: Trakt ID for a specific item.
            - startingAt: Starting date.
            - endingAt: Ending date.
         */
        public func watchedHistory(
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
                requiresAuthentication: authenticate,
                traktManager: traktManager
            )
        }

        // MARK: - Ratings

        /**
         Get a user's ratings filtered by `type`. You can optionally filter for a specific `rating` between 1 and 10. Send a comma separated string for `rating` if you need multiple ratings.

         🔓 OAuth Optional 📄 Pagination Optional ✨ Extended Info

         - parameters:
            - type: Possible values:  `movies` , `shows` , `seasons` , `episodes` , `all` .
            - rating: Filter for a specific rating. Possible values:  1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 .
         */
        public func ratings(type: String? = nil, rating: CustomStringConvertible? = nil) -> Route<PagedObject<[TraktRating]>> {
            Route(
                paths: [path, "ratings", type, rating],
                method: .GET,
                requiresAuthentication: authenticate,
                traktManager: traktManager
            )
        }

        // MARK: - Watchlist

        /**
         Returns all items in a user's watchlist filtered by type.

         ---
         **Notes**

         Each watchlist item contains a `notes` field with text entered by the user.

         ---
         **Sorting Headers**

         By default, all list items are sorted by `rank` `asc`. We send `X-Applied-Sort-By` and `X-Applied-Sort-How` headers to indicate how the results are actually being sorted.

         We also send `X-Sort-By` and `X-Sort-How` headers which indicate the user's sort preference. Use these to to custom sort the watchlist in your app for more advanced sort abilities we can't do in the API. Values for `X-Sort-By` include `rank`, `added`, `title`, `released`, `runtime`, `popularity`, `percentage`, and `votes`. Values for `X-Sort-How` include `asc` and `desc`.

         ---
         **Auto Removal**

         When an item is watched, it will be automatically removed from the watchlist. For shows and seasons, watching 1 episode will remove the entire show or season.

         ---
         **The watchlist should not be used as a list of what the user is actively watching.**

         Use a combination of the ``TraktManager/SyncResource/watchedShows()``, ``TraktManager/SyncResource/watchedMovies()`` and ``TraktManager/ShowResource/watchedProgress(includeHiddenSeasons:includeSpecials:progressCountsSpecials:)`` methods to get what the user is actively watching.

         🔓 OAuth Optional 📄 Pagination Optional ✨ Extended Info 😁 Emojis

         - parameters:
            - type: Filter for a specific item type. Possible values:  `movies` , `shows` , `seasons` , `episodes` .
            - sort: How to sort (only if type is also sent). Possible values:  `rank` , `added` , `released` , `title` .
         */
        public func watchlist(type: String? = nil, sort: String? = nil) -> Route<PagedObject<[TraktListItem]>> {
            Route(paths: [path, "watchlist", type, sort], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        /**
         Returns all top level comments for the watchlist. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, and most `replies`.

         > note: If you send OAuth, comments from blocked users will be automatically filtered out.

         🔓 OAuth Optional 📄 Pagination 😁 Emojis

         - parameter sort: How to sort. Possible values:  `newest` , `oldest` , `likes` , `replies` .
         */
        public func watchlistComments(sort: String? = nil) -> Route<PagedObject<[Comment]>> {
            Route(paths: [path, "watchlist", "comments", sort], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        // MARK: - Favorites

        // MARK: - Watching

        /**
         Returns a movie or episode if the user is currently watching something. If they are not, it returns no data and a `204` HTTP status code.

         🔓 OAuth Optional ✨ Extended Info
         */
        public func watching() -> Route<TraktWatching> {
            Route(paths: [path, "watching"], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        // MARK: - Watched

        /**
         Returns all movies or shows a user has watched sorted by most plays.

         If type is set to `shows` and you add `?extended=noseasons` to the URL, it won't return season or episode info.

         Each `movie` and `show` object contains `last_watched_at` and `last_updated_at` timestamps. Since users can set custom dates when they watched movies and episodes, it is possible for `last_watched_at` to be in the past. We also include `last_updated_at` to help sync Trakt data with your app. Cache this timestamp locally and only re-process the movies and shows if you see a newer timestamp.

         Each `show` object contains a `reset_at` timestamp. If not null, this is when the user started re-watching the show. Your app can adjust the progress by ignoring episodes with a `last_watched_at` prior to the `reset_at`.

         🔓 OAuth Optional ✨ Extended Info
         */
        public func watched(type: String) -> Route<[TraktWatchedItem]> {
            Route(
                paths: [path, "watched", type],
                method: .GET,
                requiresAuthentication: authenticate,
                traktManager: traktManager
            )
        }

        // MARK: - Stats

        /**
         Returns stats about the movies, shows, and episodes a user has watched, collected, and rated.

         🔓 OAuth Optional
         */
        public func stats() -> Route<UserStats> {
            Route(paths: [path, "stats"], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }
    }
}
