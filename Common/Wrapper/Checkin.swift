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
    @discardableResult
    public func checkIn(movie: RawJSON?, episode: RawJSON?, completionHandler: @escaping checkinCompletionHandler) throws -> URLSessionDataTaskProtocol? {
        
        // JSON
        var json: RawJSON = [
            "app_version": "1.2",
            "app_date": "2016-01-23"
        ]
        
        if let movie = movie {
            json["movie"] = movie
        } else if let episode = episode {
            json["episode"] = episode
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        
        // Request
        guard var request = mutableRequest(forPath: "checkin",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .POST) else { return nil }
        request.httpBody = jsonData
        
        return performRequest(request: request,
                              completion: completionHandler)
    }
    
    /**
     Removes any active checkins, no need to provide a specific item.
     */
    @discardableResult
    public func deleteActiveCheckins(completionHandler: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "checkin",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .DELETE) else { return nil }
        
        let dataTask = session._dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else {
                    completionHandler(.fail)
                    return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                (HTTPResponse.statusCode == StatusCodes.SuccessNoContentToReturn || HTTPResponse.statusCode == StatusCodes.Success)
                else {
                    completionHandler(.fail)
                    return
            }
            completionHandler(.success)
        }
        dataTask.resume()
        return dataTask
    }
}
