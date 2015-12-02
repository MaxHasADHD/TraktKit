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
    public func postComment(movie movie: String?, show: String?, episode: String?, comment: String, isSpoiler spoiler: Bool, isReview review: Bool, completionHandler: successCompletionHandler) -> NSURLSessionDataTask? {
        // JSON
        var jsonString = String()
        
        jsonString += "{" // Beginning
        if let movie = movie {
            jsonString += "\"movie\":" // Begin Movie
            jsonString += movie // Add Movie
            jsonString += "," // End Movie
        }
        else if let show = show {
            jsonString += "\"show\":" // Begin Show
            jsonString += show // Add Show
            jsonString += "," // End Show
        }
        else if let episode = episode {
            jsonString += "\"episode\": " // Begin Episode
            jsonString += episode // Add Episode
            jsonString += "," // End Episode
        }
        let fixedComment = comment.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        jsonString += "\"comment\": \"\(fixedComment)\","
        jsonString += "\"spoiler\": \(spoiler),"
        jsonString += "\"review\": \(review)"
        jsonString += "}" // End
        
        #if DEBUG
            print(jsonString)
        #endif
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        guard let request = mutableRequestForURL("comments", authorization: true, HTTPMethod: "POST") else {
            return nil
        }
        request.HTTPBody = jsonData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNewResourceCreated, completion: completionHandler)
    }
    
    /**
     Returns a single comment and indicates how many replies it has. Use **GET** `/comments/:id/replies` to get the actual replies.
     */
    public func getComment<T: CustomStringConvertible>(commentID id: T, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Update a single comment created within the last hour. The OAuth user must match the author of the comment in order to update it.
     
     🔒 OAuth: Required
     */
    public func updateComment<T: CustomStringConvertible>(commentID id: T, newComment: String, isSpoiler: Bool = false, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        
        // JSON
        var jsonString = String()
        
        jsonString += "{" // Beginning
        jsonString += "\"comment\": \"\(newComment)\","
        jsonString += "\"spoiler\": \"\(isSpoiler)\""
        jsonString += "}" // End
        
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        guard let request = mutableRequestForURL("comments/\(id)", authorization: true, HTTPMethod: "PUT") else { return nil }
        request.HTTPBody = jsonData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Delete a single comment created within the last hour. This also effectively removes any replies this comment has. The OAuth user must match the author of the comment in order to delete it.
     
     🔒 OAuth: Required
     */
    public func deleteComment<T: CustomStringConvertible>(commentID id: T, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)", authorization: true, HTTPMethod: "DELETE") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNoContentToReturn, completion: completion)
    }
    
    // MARK: - Replies
    
    /**
    Returns all replies for a comment. It is possible these replies could have replies themselves, so in that case you would just call **GET** `/comments/:id/replies` again with the new comment `id`.
    
    📄 Pagination
    */
    public func getReplies<T: CustomStringConvertible>(commentID id: T, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)/replies", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Add a new reply to an existing comment. Make sure to allow and encourage spoilers to be indicated in your app and follow the rules listed above.
     
     🔒 OAuth: Required
     */
    public func postReply<T: CustomStringConvertible>(commentID id: T, newComment: String, isSpoiler: Bool = false, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        
        // JSON
        var jsonString = String()
        
        jsonString += "{" // Beginning
        jsonString += "\"comment\": \"\(newComment)\","
        jsonString += "\"spoiler\": \"\(isSpoiler)\""
        jsonString += "}" // End
        
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Request
        guard let request = mutableRequestForURL("comments/\(id)/replies", authorization: true, HTTPMethod: "POST") else { return nil }
        request.HTTPBody = jsonData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Like
    
    /**
    Votes help determine popular comments. Only one like is allowed per comment per user.
    
    🔒 OAuth: Required
    */
    public func likeComment<T: CustomStringConvertible>(commentID id: T, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)/like", authorization: false, HTTPMethod: "POST") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNoContentToReturn, completion: completion)
    }
    
    /**
     Remove a like on a comment.
     
     🔒 OAuth: Required
     */
    public func removeLikeOnComment<T: CustomStringConvertible>(commentID id: T, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("comments/\(id)/like", authorization: false, HTTPMethod: "DELETE") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNoContentToReturn, completion: completion)
    }
}
