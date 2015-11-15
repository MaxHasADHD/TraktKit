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
    public func postComment(movie movie: String?, show: String?, episode: String?, comment: String, isSpoiler spoiler: Bool, isReview review: Bool, completionHandler: successCompletionHandler) {
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
            return
        }
        request.HTTPBody = jsonData
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completionHandler(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    completionHandler(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completionHandler(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completionHandler(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completionHandler(success: false)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                completionHandler(success: false)
            }
            }.resume()
    }
    
    /**
     
     */
    public func getComment() {
        
    }
    
    /**
     
     */
    public func updateComment() {
        
    }
    
    /**
     
     */
    public func deleteComment() {
        
    }
    
    // MARK: - Replies
    
    /**
    
    */
    public func getReplies() {
        
    }
    
    /**
     
     */
    public func postReply() {
        
    }
    
    // MARK: - Like
    
    /**
    
    */
    public func likeComment() {
        
    }
    
    /**
     
     */
    public func removeLikeOnComment() {
        
    }
}
