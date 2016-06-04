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
    public func postComment(movie movie: RawJSON?, show: RawJSON?, episode: RawJSON?, comment: String, isSpoiler spoiler: Bool, isReview review: Bool, completionHandler: SuccessCompletionHandler) throws -> NSURLSessionDataTask? {
        
        // JSON
        var json: RawJSON = [
            "comment": comment,
            "spoiler": spoiler,
            "review": review
        ]
        
        if let movie = movie {
            json["movie"] = movie
        }
        else if let show = show {
            json["show"] = show
        }
        else if let episode = episode {
            json["episode"] = episode
        }

        let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        
        // Request
        guard let request = mutableRequestForURL("comments", authorization: true, HTTPMethod: .POST) else {
            return nil
        }
        request.HTTPBody = jsonData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNewResourceCreated, completion: completionHandler)
    }
    
    /**
     Returns a single comment and indicates how many replies it has. Use **GET** `/comments/:id/replies` to get the actual replies.
     */
    public func getComment<T: CustomStringConvertible>(commentID id: T, completion: ResultCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Update a single comment created within the last hour. The OAuth user must match the author of the comment in order to update it.
     
     🔒 OAuth: Required
     */
    public func updateComment<T: CustomStringConvertible>(commentID id: T, newComment: String, isSpoiler: Bool = false, completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        
        // JSON
        let json: RawJSON = [
            "comment": newComment,
            "spoiler": isSpoiler,
        ]
        
        let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        
        // Request
        guard let request = mutableRequestForURL("comments/\(id)", authorization: true, HTTPMethod: .PUT) else { return nil }
        request.HTTPBody = jsonData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Delete a single comment created within the last hour. This also effectively removes any replies this comment has. The OAuth user must match the author of the comment in order to delete it.
     
     🔒 OAuth: Required
     */
    public func deleteComment<T: CustomStringConvertible>(commentID id: T, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)", authorization: true, HTTPMethod: .DELETE) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNoContentToReturn, completion: completion)
    }
    
    // MARK: - Replies
    
    /**
    Returns all replies for a comment. It is possible these replies could have replies themselves, so in that case you would just call **GET** `/comments/:id/replies` again with the new comment `id`.
    
    📄 Pagination
    */
    public func getReplies<T: CustomStringConvertible>(commentID id: T, completion: ArrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)/replies", authorization: false, HTTPMethod: .GET) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Add a new reply to an existing comment. Make sure to allow and encourage spoilers to be indicated in your app and follow the rules listed above.
     
     🔒 OAuth: Required
     */
    public func postReply<T: CustomStringConvertible>(commentID id: T, newComment: String, isSpoiler: Bool = false, completion: ResultCompletionHandler) throws -> NSURLSessionDataTask? {
        
        // JSON
        let json: RawJSON = [
            "comment": newComment,
            "spoiler": isSpoiler,
        ]

        let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        
        // Request
        guard let request = mutableRequestForURL("comments/\(id)/replies", authorization: true, HTTPMethod: .POST) else { return nil }
        request.HTTPBody = jsonData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Like
    
    /**
    Votes help determine popular comments. Only one like is allowed per comment per user.
    
    🔒 OAuth: Required
    */
    public func likeComment<T: CustomStringConvertible>(commentID id: T, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)/like", authorization: false, HTTPMethod: .POST) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNoContentToReturn, completion: completion)
    }
    
    /**
     Remove a like on a comment.
     
     🔒 OAuth: Required
     */
    public func removeLikeOnComment<T: CustomStringConvertible>(commentID id: T, completion: SuccessCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)/like", authorization: false, HTTPMethod: .DELETE) else { return nil }
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.SuccessNoContentToReturn, completion: completion)
    }
}
