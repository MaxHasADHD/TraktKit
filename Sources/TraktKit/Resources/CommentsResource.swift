//
//  CommentsResource.swift
//  TraktKit
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /**
     Comments are attached to movies, shows, seasons, episodes, and lists. Each comment is a shout or a full review with at least 200 words. A spoiler can be indicated for each comment separately.
     */
    public struct CommentsResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Post

        /**
         Add a new comment to a movie, show, season, episode, or list.

         **Endpoint:** `POST /comments`

         🔒 OAuth Required • 😁 Emojis

         - parameter body: The comment body containing the media item, comment text, and optional spoiler flag.
         */
        public func post(_ body: TraktCommentPostBody) -> Route<Comment> {
            Route(paths: ["comments"], body: body, method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: - Trending

        /**
         Returns all comments with the most likes and replies over the last 7 days. You can optionally filter by the `commentType` and media `type`.

         **Endpoint:** `GET /comments/trending/{comment_type}/{type}`

         📄 Pagination • ✨ Extended Info

         - parameter commentType: Filter by comment type.
         - parameter type: Filter by media type.
         - parameter includeReplies: Include replies alongside top level comments.
         */
        public func trending(commentType: CommentType, type: Type2, includeReplies: Bool = false) -> Route<PagedObject<[TraktTrendingComment]>> {
            Route(
                path: "comments/trending/\(commentType.rawValue)/\(type.rawValue)",
                queryItems: ["include_replies": "\(includeReplies)"],
                method: .GET,
                requiresAuthentication: false,
                traktManager: traktManager
            )
        }

        // MARK: - Recent

        /**
         Returns the most recently written comments across all of Trakt. You can optionally filter by the `commentType` and media `type`.

         **Endpoint:** `GET /comments/recent/{comment_type}/{type}`

         📄 Pagination • ✨ Extended Info

         - parameter commentType: Filter by comment type.
         - parameter type: Filter by media type.
         - parameter includeReplies: Include replies alongside top level comments.
         */
        public func recent(commentType: CommentType, type: Type2, includeReplies: Bool = false) -> Route<PagedObject<[TraktTrendingComment]>> {
            Route(
                path: "comments/recent/\(commentType.rawValue)/\(type.rawValue)",
                queryItems: ["include_replies": "\(includeReplies)"],
                method: .GET,
                requiresAuthentication: false,
                traktManager: traktManager
            )
        }

        // MARK: - Updates

        /**
         Returns the most recently updated comments across all of Trakt. You can optionally filter by the `commentType` and media `type`.

         **Endpoint:** `GET /comments/updates/{comment_type}/{type}`

         📄 Pagination • ✨ Extended Info

         - parameter commentType: Filter by comment type.
         - parameter type: Filter by media type.
         - parameter includeReplies: Include replies alongside top level comments.
         */
        public func updates(commentType: CommentType, type: Type2, includeReplies: Bool = false) -> Route<PagedObject<[TraktTrendingComment]>> {
            Route(
                path: "comments/updates/\(commentType.rawValue)/\(type.rawValue)",
                queryItems: ["include_replies": "\(includeReplies)"],
                method: .GET,
                requiresAuthentication: false,
                traktManager: traktManager
            )
        }
    }

    /**
     Endpoints scoped to a single comment by its ID.
     */
    public struct CommentResource {
        private let id: CustomStringConvertible
        private let traktManager: TraktManager

        internal init(id: CustomStringConvertible, traktManager: TraktManager) {
            self.id = id
            self.traktManager = traktManager
        }

        // MARK: - Comment

        /**
         Returns a single comment and indicates how many replies it has.

         **Endpoint:** `GET /comments/{id}`
         */
        public func get() -> Route<Comment> {
            Route(paths: ["comments", id], method: .GET, requiresAuthentication: false, traktManager: traktManager)
        }

        /**
         Update a single comment created within the last hour. The OAuth user must match the author of the comment.

         **Endpoint:** `PUT /comments/{id}`

         🔒 OAuth Required • 😁 Emojis

         - parameter body: The updated comment body.
         */
        public func update(_ body: TraktCommentPostBody) -> Route<Comment> {
            Route(paths: ["comments", id], body: body, method: .PUT, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Delete a single comment created within the last hour. The OAuth user must match the author of the comment.

         **Endpoint:** `DELETE /comments/{id}`

         🔒 OAuth Required
         */
        public func delete() -> EmptyRoute {
            EmptyRoute(paths: ["comments", id], method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: - Replies

        /**
         Returns all replies for a comment.

         **Endpoint:** `GET /comments/{id}/replies`

         📄 Pagination
         */
        public func replies() -> Route<PagedObject<[Comment]>> {
            Route(paths: ["comments", id, "replies"], method: .GET, requiresAuthentication: false, traktManager: traktManager)
        }

        /**
         Add a new reply to an existing comment.

         **Endpoint:** `POST /comments/{id}/replies`

         🔒 OAuth Required • 😁 Emojis

         - parameter body: The reply body.
         */
        public func postReply(_ body: TraktCommentPostBody) -> Route<Comment> {
            Route(paths: ["comments", id, "replies"], body: body, method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: - Item

        /**
         Returns the media item this comment is attached to. The media type can be `movie`, `show`, `season`, `episode`, or `list`.

         **Endpoint:** `GET /comments/{id}/item`

         ✨ Extended Info
         */
        public func item() -> Route<TraktAttachedMediaItem> {
            Route(paths: ["comments", id, "item"], method: .GET, requiresAuthentication: false, traktManager: traktManager)
        }

        // MARK: - Likes

        /**
         Returns all users who liked a comment.

         **Endpoint:** `GET /comments/{id}/likes`

         📄 Pagination
         */
        public func likes() -> Route<PagedObject<[TraktCommentLikedUser]>> {
            Route(paths: ["comments", id, "likes"], method: .GET, requiresAuthentication: false, traktManager: traktManager)
        }

        // MARK: - Like

        /**
         Votes help determine popular comments. Only one like is allowed per comment per user.

         **Endpoint:** `POST /comments/{id}/like`

         🔒 OAuth Required
         */
        public func like() -> EmptyRoute {
            EmptyRoute(paths: ["comments", id, "like"], method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Remove a like on a comment.

         **Endpoint:** `DELETE /comments/{id}/like`

         🔒 OAuth Required
         */
        public func removeLike() -> EmptyRoute {
            EmptyRoute(paths: ["comments", id, "like"], method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }
    }
}
