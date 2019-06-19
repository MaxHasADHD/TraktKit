//
//  Scrobble.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Start
    
    /**
     Use this method when the video intially starts playing or is unpaused. This will remove any playback progress if it exists.
     
     **Note**: A watching status will auto expire after the remaining runtime has elpased. There is no need to re-send every 15 minutes.
     
     🔒 OAuth: Required
     
     - parameter movie: Standard `Movie` object
     - parameter progress: Progress percentage between 0 and 100.
     - parameter appVersion: Version number of the app.
     - parameter appBuildDate: Build date of the app.
     */
    @discardableResult
    public func scrobbleStart(movie: RawJSON, progress: Float, appVersion: Float, appBuildDate: Date, completion: @escaping ObjectCompletionHandler<ScrobbleResult>) throws -> URLSessionDataTaskProtocol? {
        return try scrobble("start",
                            movie: movie,
                            episode: nil,
                            progress: progress,
                            appVersion: appVersion,
                            appBuildDate: appBuildDate,
                            completion: completion)
    }
    
    /**
     Use this method when the video intially starts playing or is unpaused. This will remove any playback progress if it exists.
     
     **Note**: A watching status will auto expire after the remaining runtime has elpased. There is no need to re-send every 15 minutes.
     
     🔒 OAuth: Required
     
     - parameter episode: Standard `Episode` object
     - parameter progress: Progress percentage between 0 and 100.
     - parameter appVersion: Version number of the app.
     - parameter appBuildDate: Build date of the app.
     */
    @discardableResult
    public func scrobbleStart(episode: RawJSON, progress: Float, appVersion: Float, appBuildDate: Date, completion: @escaping ObjectCompletionHandler<ScrobbleResult>) throws -> URLSessionDataTaskProtocol? {
        return try scrobble("start",
                            movie: nil,
                            episode: episode,
                            progress: progress,
                            appVersion: appVersion,
                            appBuildDate: appBuildDate,
                            completion: completion)
    }
    
    // MARK: - Pause
    
    /**
     Use this method when the video is paused. The playback progress will be saved and **GET** `/sync/playback` can be used to resume the video from this exact position. Unpause a video by calling the **GET** `/scrobble/start` method again.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func scrobblePause(movie: RawJSON, progress: Float, appVersion: Float, appBuildDate: Date, completion: @escaping ObjectCompletionHandler<ScrobbleResult>) throws -> URLSessionDataTaskProtocol? {
        return try scrobble("pause",
                            movie: movie,
                            episode: nil,
                            progress: progress,
                            appVersion: appVersion,
                            appBuildDate: appBuildDate,
                            completion: completion)
    }
    
    /**
     Use this method when the video is paused. The playback progress will be saved and **GET** `/sync/playback` can be used to resume the video from this exact position. Unpause a video by calling the **GET** `/scrobble/start` method again.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func scrobblePause(episode: RawJSON, progress: Float, appVersion: Float, appBuildDate: Date, completion: @escaping ObjectCompletionHandler<ScrobbleResult>) throws -> URLSessionDataTaskProtocol? {
        return try scrobble("pause",
                            movie: nil,
                            episode: episode,
                            progress: progress,
                            appVersion: appVersion,
                            appBuildDate: appBuildDate,
                            completion: completion)
    }
    
    // MARK: - Stop
    
    /**
     Use this method when the video is stopped or finishes playing on its own. If the progress is above 80%, the video will be scrobbled and the action will be set to **scrobble**.
     
     If the progress is less than 80%, it will be treated as a pause and the `action` will be set to `pause`. The playback progress will be saved and **GET** `/sync/playback` can be used to resume the video from this exact position.
     
     **Note**: If you prefer to use a threshold higher than 80%, you should use **GET** `/scrobble/pause` yourself so it doesn't create duplicate scrobbles.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func scrobbleStop(movie: RawJSON, progress: Float, appVersion: Float, appBuildDate: Date, completion: @escaping ObjectCompletionHandler<ScrobbleResult>) throws -> URLSessionDataTaskProtocol? {
        return try scrobble("stop",
                            movie: movie,
                            episode: nil,
                            progress: progress,
                            appVersion: appVersion,
                            appBuildDate: appBuildDate,
                            completion: completion)
    }
    
    /**
     Use this method when the video is stopped or finishes playing on its own. If the progress is above 80%, the video will be scrobbled and the action will be set to **scrobble**.
     
     If the progress is less than 80%, it will be treated as a pause and the `action` will be set to `pause`. The playback progress will be saved and **GET** `/sync/playback` can be used to resume the video from this exact position.
     
     **Note**: If you prefer to use a threshold higher than 80%, you should use **GET** `/scrobble/pause` yourself so it doesn't create duplicate scrobbles.
     
     🔒 OAuth: Required
     */
    @discardableResult
    public func scrobbleStop(episode: RawJSON, progress: Float, appVersion: Float, appBuildDate: Date, completion: @escaping ObjectCompletionHandler<ScrobbleResult>) throws -> URLSessionDataTaskProtocol? {
        return try scrobble("stop",
                            movie: nil,
                            episode: episode,
                            progress: progress,
                            appVersion: appVersion,
                            appBuildDate: appBuildDate,
                            completion: completion)
    }
    
    // MARK: - Private
    
    @discardableResult
    func scrobble(_ scrobbleAction: String, movie: RawJSON?, episode: RawJSON?, progress: Float, appVersion: Float, appBuildDate: Date, completion: @escaping ObjectCompletionHandler<ScrobbleResult>) throws -> URLSessionDataTaskProtocol? {
        // JSON
        var json: RawJSON = [
            "progress": progress,
            "appVersion": appVersion,
            "appBuildDate": appBuildDate.dateString(withFormat: "yyyy-MM-dd")
        ]
        
        if let movie = movie {
            json["movie"] = movie
        }
        else if let episode = episode {
            json["episode"] = episode
        }
        
        // Request
        guard var request = mutableRequest(forPath: "scrobble/\(scrobbleAction)",
            withQuery: [:],
            isAuthorized: true,
            withHTTPMethod: .POST) else { return nil }
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        return performRequest(request: request,
                              completion: completion)
    }
}
