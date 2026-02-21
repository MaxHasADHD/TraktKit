//
//  ListResource.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/19/26.
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /// Endpoints for lists in general (not specific to a single list).
    public struct ListsResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Trending

        /**
         Returns all lists with the most likes and comments over the last 7 days.

         **Endpoint:** `GET /lists/trending`

         📄 Pagination • 😁 Emojis
         */
        public func trending() -> Route<PagedObject<[TraktTrendingList]>> {
            Route(path: "lists/trending", method: .GET, traktManager: traktManager)
        }

        // MARK: - Popular

        /**
         Returns the most popular lists. Popularity is calculated using the total number of likes and comments.

         **Endpoint:** `GET /lists/popular`

         📄 Pagination • 😁 Emojis
         */
        public func popular() -> Route<PagedObject<[TraktTrendingList]>> {
            Route(path: "lists/popular", method: .GET, traktManager: traktManager)
        }
    }

    /// Endpoints for a specific list identified by its Trakt ID or slug.
    public struct ListResource {

        // MARK: - Properties

        /// Trakt ID or Trakt slug
        public let id: CustomStringConvertible
        private let path: String
        private let traktManager: TraktManager

        // MARK: - Lifecycle

        internal init(id: CustomStringConvertible, traktManager: TraktManager) {
            self.id = id
            self.traktManager = traktManager
            self.path = "lists/\(id)"
        }

        // MARK: - Summary

        /**
         Returns a single list. Use the ``TraktManager/ListResource/items(type:)`` method to get the actual items this list contains.

         **Endpoint:** `GET /lists/{id}`

         😁 Emojis
         */
        public func summary() -> Route<TraktList> {
            Route(paths: [path], method: .GET, traktManager: traktManager)
        }

        // MARK: - Items

        /**
         Returns all items on a list. Items can be a `movie`, `show`, `season`, `episode`, or `person`. You can optionally specify the `type` to limit what gets returned.

         Each list item contains a `notes` field with text entered by the user.

         **Endpoint:** `GET /lists/{id}/items/{type}`

         📄 Pagination • ✨ Extended Info • 😁 Emojis

         - parameter type: Filter for a specific item type. Possible values: `movie`, `show`, `season`, `episode`, `person`.
         */
        public func items(type: ListItemType? = nil) -> Route<PagedObject<[TraktListItem]>> {
            Route(paths: [path, "items", type?.rawValue], method: .GET, traktManager: traktManager)
        }

        // MARK: - Comments

        /**
         Returns all top level comments for a list. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, and most `replies`.

         > note: If you send OAuth, comments from blocked users will be automatically filtered out.

         **Endpoint:** `GET /lists/{id}/comments/{sort}`

         🔓 OAuth Optional • 📄 Pagination • 😁 Emojis

         - parameter sort: How to sort. Possible values: `newest`, `oldest`, `likes`, `replies`.
         */
        public func comments(sort: String? = nil, authenticate: Bool = false) -> Route<PagedObject<[Comment]>> {
            Route(paths: [path, "comments", sort], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
        }

        // MARK: - Likes

        /**
         Returns all users who liked a list.

         **Endpoint:** `GET /lists/{id}/likes`

         📄 Pagination
         */
        public func likes() -> Route<PagedObject<[Like]>> {
            Route(paths: [path, "likes"], method: .GET, traktManager: traktManager)
        }

        /**
         Like a list. This sends a notification to the list owner.

         **Endpoint:** `POST /lists/{id}/like`

         🔒 OAuth Required
         */
        public func like() -> EmptyRoute {
            EmptyRoute(paths: [path, "like"], method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Remove a like on a list.

         **Endpoint:** `DELETE /lists/{id}/like`

         🔒 OAuth Required
         */
        public func removeLike() -> EmptyRoute {
            EmptyRoute(paths: [path, "like"], method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }
    }
}
