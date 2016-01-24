//
//  Checkin.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/15/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Check into a movie or episode. This should be tied to a user action to manually indicate they are watching something. The item will display as watching on the site, then automatically switch to watched status once the duration has elapsed.
     
     **Note**: If a checkin is already in progress, a `409` HTTP status code will returned. The response will contain an `expires_at` timestamp which is when the user can check in again.
     */
    public func checkIn(movie movie: RawJSON?, episode: RawJSON?, completionHandler: successCompletionHandler) -> NSURLSessionDataTask? {
        
        // JSON
        var json: RawJSON = [
            "app_version": "1.2",
            "app_date": "2016-01-23"
        ]
        
        if let movie = movie {
            json["movie"] = movie
        }
        else if let episode = episode {
            json["episode"] = episode
        }
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        
        // Request
        guard let request = mutableRequestForURL("checkin", authorization: true, HTTPMethod: "POST") else { return nil }
        request.HTTPBody = jsonData
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completionHandler(success: false)
                return
            }
            
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where (HTTPResponse.statusCode == statusCodes.successNewResourceCreated ||
                    HTTPResponse.statusCode == statusCodes.conflict) else {
                        #if DEBUG
                            print("[\(__FUNCTION__)] \(response)")
                        #endif
                        completionHandler(success: false)
                        return
            }
            
            if HTTPResponse.statusCode == statusCodes.successNewResourceCreated {
                // Started watching
                completionHandler(success: true)
            }
            else {
                // Already watching something
                #if DEBUG
                    print("[\(__FUNCTION__)] Already watching a show")
                #endif
                completionHandler(success: false)
            }
        }
        dataTask.resume()
        
        return dataTask
    }
    
    /**
     Removes any active checkins, no need to provide a specific item.
     */
    public func deleteActiveCheckins(completionHandler: successCompletionHandler) -> NSURLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL("checkin", authorization: true, HTTPMethod: "DELETE") else {
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completionHandler(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNoContentToReturn else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    completionHandler(success: false)
                    return
            }
            
            print("Cancelled check-in")
            
            completionHandler(success: true)
        }
        dataTask.resume()
        
        return dataTask
    }
    
}
