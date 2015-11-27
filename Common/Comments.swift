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
     
     */
    public func getComment() {
        fatalError("\(__FUNCTION__) Not implemented yet")
    }
    
    /**
     
     */
    public func updateComment() {
        fatalError("\(__FUNCTION__) Not implemented yet")
    }
    
    /**
     
     */
    public func deleteComment() {
        fatalError("\(__FUNCTION__) Not implemented yet")
    }
    
    // MARK: - Replies
    
    /**
    
    */
    public func getReplies() {
        fatalError("\(__FUNCTION__) Not implemented yet")
    }
    
    /**
     
     */
    public func postReply() {
        fatalError("\(__FUNCTION__) Not implemented yet")
    }
    
    // MARK: - Like
    
    /**
    
    */
    public func likeComment() {
        fatalError("\(__FUNCTION__) Not implemented yet")
    }
    
    /**
     
     */
    public func removeLikeOnComment() {
        fatalError("\(__FUNCTION__) Not implemented yet")
    }
}
