//
//  UserResource.swift
//  
//
//  Created by Maximilian Litteral on 9/9/22.
//

import Foundation

extension TraktManager {
    /// Resource for authenticated user
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
                paths: [
                    "users/hidden",
                    section
                ],
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
        public func hide(movies: [SyncId], shows: [SyncId], seasons: [SyncId], users: [SyncId], in section: String) -> Route<HideItemResult> {
            Route(
                paths: [
                    "users/hidden",
                    section
                ],
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
        public func unhide(movies: [SyncId], shows: [SyncId], seasons: [SyncId], users: [SyncId], in section: String) -> Route<UnhideItemResult> {
            Route(
                paths: [
                    "users/hidden/remove",
                    section
                ],
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
            UsersResource(slug: Self.currentUserSlug, traktManager: traktManager).profile(authenticate: true)
        }
    }

    /// Resource for /Users/id
    public struct UsersResource {
        public let slug: String
        private let path: String
        private let traktManager: TraktManager

        internal init(slug: String, traktManager: TraktManager) {
            self.slug = slug
            self.path = "users/\(slug)"
            self.traktManager = traktManager
        }
        
        // MARK: - Methods

        /**
         Get a user's profile information. If the user is private, info will only be returned if you send OAuth and are either that user or an approved follower. Adding `?extended=vip` will return some additional VIP related fields so you can display the user's Trakt VIP status and year count.

         🔓 OAuth Optional ✨ Extended Info
         */
        public func profile(authenticate: Bool = false) -> Route<User> {
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
        public func likes(type: String? = nil, authenticate: Bool = false) -> Route<PagedObject<[Like]>> {
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
        public func collection(type: String, authenticate: Bool = false) -> Route<[TraktCollectedItem]> {
            Route(paths: [path, "collection", type], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        // MARK: - Comments

        /**
         Returns the most recently written comments for the user. You can optionally filter by the `comment_type` and media `type` to limit what gets returned.

         By default, only top level comments are returned. Set `?include_replies=true` to return replies in addition to top level comments. Set `?include_replies=only` to return only replies and no top level comments.

         🔓 OAuth Optional 📄 Pagination ✨ Extended Info
         */
        public func comments(commentType: String? = nil, mediaType: String? = nil, includeReplies: String? = nil, authenticate: Bool = false) -> Route<PagedObject<[UsersComments]>> {
            Route(
                paths: [
                    path,
                    "comments",
                    commentType,
                    mediaType
                ],
                queryItems: ["include_replies": includeReplies].compactMapValues { $0 },
                method: .GET,
                requiresAuthentication: authenticate,
                traktManager: traktManager
            )
        }

        // MARK: Settings

        public func lists() -> Route<[TraktList]> {
            Route(paths: [path, "lists"], method: .GET, traktManager: traktManager)
        }
        
        public func itemsOnList(_ listId: String, type: ListItemType? = nil) -> Route<[TraktListItem]> {
            Route(paths: ["users/\(slug)/lists/\(listId)/items", type?.rawValue], method: .GET, traktManager: traktManager)
        }
    }
}
