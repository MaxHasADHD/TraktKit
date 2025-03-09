//
//  Comments.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/15/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Comments
    
    /**
     Add a new comment to a movie, show, season, episode, or list. Make sure to allow and encourage spoilers to be indicated in your app and follow the rules listed above.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func postComment(movie: SyncId? = nil, show: SyncId? = nil, season: SyncId? = nil, episode: SyncId? = nil, list: SyncId? = nil, comment: String, isSpoiler spoiler: Bool? = nil, completion: @escaping SuccessCompletionHandler) throws -> URLSessionDataTask? {
        let body = TraktCommentBody(movie: movie, show: show, season: season, episode: episode, list: list, comment: comment, spoiler: spoiler)
        let request = try post("comments", body: body)
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Returns a single comment and indicates how many replies it has. Use **GET** `/comments/:id/replies` to get the actual replies.
     */
    @discardableResult
    public func getComment(commentID id: CustomStringConvertible, completion: @escaping ObjectCompletionHandler<Comment>) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/\(id)",
                                          withQuery: [:],
                                          isAuthorized: false,
                                          withHTTPMethod: .GET)
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Update a single comment created within the last hour. The OAuth user must match the author of the comment in order to update it.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func updateComment(commentID id: CustomStringConvertible, newComment comment: String, isSpoiler spoiler: Bool? = nil, completion: @escaping ObjectCompletionHandler<Comment>) throws -> URLSessionDataTask? {
        let body = TraktCommentBody(comment: comment, spoiler: spoiler)
        var request = try mutableRequest(forPath: "comments/\(id)",
                                          withQuery: [:],
                                          isAuthorized: true,
                                          withHTTPMethod: .PUT)
        request.httpBody = try Self.jsonEncoder.encode(body)
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Delete a single comment created within the last hour. This also effectively removes any replies this comment has. The OAuth user must match the author of the comment in order to delete it.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func deleteComment(commentID id: CustomStringConvertible, completion: @escaping SuccessCompletionHandler) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/\(id)",
                                          withQuery: [:],
                                          isAuthorized: true,
                                          withHTTPMethod: .DELETE)
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Replies
    
    /**
     Returns all replies for a comment. It is possible these replies could have replies themselves, so in that case you would just call **GET** `/comments/:id/replies` again with the new comment `id`.
     
     📄 Pagination
     */
    @discardableResult
    public func getReplies(commentID id: CustomStringConvertible, completion: @escaping ObjectCompletionHandler<[Comment]>) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/\(id)/replies",
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET)
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Add a new reply to an existing comment. Make sure to allow and encourage spoilers to be indicated in your app and follow the rules listed above.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func postReply(commentID id: CustomStringConvertible, comment: String, isSpoiler spoiler: Bool? = nil, completion: @escaping ObjectCompletionHandler<Comment>) throws -> URLSessionDataTask? {
        let body = TraktCommentBody(comment: comment, spoiler: spoiler)
        let request = try post("comments/\(id)/replies", body: body)
        return performRequest(request: request, completion: completion)
    }

    // MARK: - Item

    /**
     Returns all users who liked a comment. If you only need the `replies` count, the main `comment` object already has that, so no need to use this method.

     📄 Pagination
     */
    @discardableResult
    public func getAttachedMediaItem(commentID id: CustomStringConvertible, completion: @escaping ObjectCompletionHandler<TraktAttachedMediaItem>) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/\(id)/item",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .POST)
        return performRequest(request: request, completion: completion)
    }

    // MARK: - Likes

    /**
     Returns the media item this comment is attached to. The media type can be `movie`, `show`, `season`, `episode`, or `list` and it also returns the standard media object for that media type.

     ✨ Extended Info
     */
    @discardableResult
    public func getUsersWhoLikedComment(commentID id: CustomStringConvertible, completion: @escaping ObjectCompletionHandler<[TraktCommentLikedUser]>) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/\(id)/likes",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET)
        return performRequest(request: request, completion: completion)
    }

    // MARK: - Like
    
    /**
     Votes help determine popular comments. Only one like is allowed per comment per user.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func likeComment(commentID id: CustomStringConvertible, completion: @escaping SuccessCompletionHandler) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/\(id)/like",
                                          withQuery: [:],
                                          isAuthorized: false,
                                          withHTTPMethod: .POST)
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Remove a like on a comment.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func removeLikeOnComment(commentID id: CustomStringConvertible, completion: @escaping SuccessCompletionHandler) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/\(id)/like",
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .DELETE)
        return performRequest(request: request, completion: completion)
    }

    // MARK: - Trending

    /**
     Returns all comments with the most likes and replies over the last 7 days. You can optionally filter by the `comment_type` and media `type` to limit what gets returned. If you want to `include_replies` that will return replies in place alongside top level comments.

     📄 Pagination
     ✨ Extended
     */
    @discardableResult
    public func getTrendingComments(commentType: CommentType, mediaType: Type2, includeReplies: Bool, completion: @escaping ObjectCompletionHandler<[TraktTrendingComment]>) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/trending/\(commentType.rawValue)/\(mediaType.rawValue)",
                                          withQuery: ["include_replies": "\(includeReplies)"],
                                          isAuthorized: false,
                                          withHTTPMethod: .GET)
        return performRequest(request: request, completion: completion)
    }

    // MARK: - Recent

    /**
     Returns the most recently written comments across all of Trakt. You can optionally filter by the `comment_type` and media `type` to limit what gets returned. If you want to `include_replies` that will return replies in place alongside top level comments.

     📄 Pagination
     ✨ Extended
     */
    @discardableResult
    public func getRecentComments(commentType: CommentType, mediaType: Type2, includeReplies: Bool, completion: @escaping ObjectCompletionHandler<[TraktTrendingComment]>) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/recent/\(commentType.rawValue)/\(mediaType.rawValue)",
                                          withQuery: ["include_replies": "\(includeReplies)"],
                                          isAuthorized: false,
                                          withHTTPMethod: .GET)
        return performRequest(request: request, completion: completion)
    }

    // MARK: - Updates

    /**
     Returns the most recently updated comments across all of Trakt. You can optionally filter by the `comment_type` and media `type` to limit what gets returned. If you want to `include_replies` that will return replies in place alongside top level comments.

     📄 Pagination
     ✨ Extended
     */
    @discardableResult
    public func getRecentlyUpdatedComments(commentType: CommentType, mediaType: Type2, includeReplies: Bool, completion: @escaping ObjectCompletionHandler<[TraktTrendingComment]>) throws -> URLSessionDataTask? {
        let request = try mutableRequest(forPath: "comments/updates/\(commentType.rawValue)/\(mediaType.rawValue)",
                                          withQuery: ["include_replies": "\(includeReplies)"],
                                          isAuthorized: false,
                                          withHTTPMethod: .GET)
        return performRequest(request: request, completion: completion)
    }
}
