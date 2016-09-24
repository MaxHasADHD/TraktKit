//
//  TraktWatchedProgress.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/31/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Watched progress. Shows/Progress/Watched
public struct TraktShowWatchedProgress: TraktProtocol {
    // Extended: Min
    /// Number of episodes that have aired
    public let aired: Int
    /// Number of episodes that have been watched
    public let completed: Int
    /// When the last episode was watched
    public let lastWatchedAt: Date?
    public let seasons: [TraktSeasonWatchedProgress]
    public let nextEpisode: TraktEpisode?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let aired = json["aired"] as? Int,
            let completed = json["completed"] as? Int else { return nil }
        
        self.aired = aired
        self.completed = completed
        self.lastWatchedAt = Date.dateFromString(json["last_watched_at"])
        self.nextEpisode = TraktEpisode(json: json["next_episode"] as? RawJSON)
        
        if let jsonSeasons = json["seasons"] as? [RawJSON] {
            seasons = initEach(jsonSeasons)
        }
        else {
            seasons = []
        }
    }
}

public struct TraktSeasonWatchedProgress: TraktProtocol {
    // Extended: Min
    /// Season number
    public let number: Int
    /// Number of episodes that have aired
    public let aired: Int
    /// Number of episodes that have been watched
    public let completed: Int
    public let episodes: [TraktEpisodeWatchedProgress]
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let number = json["number"] as? Int,
            let aired = json["aired"] as? Int,
            let completed = json["completed"] as? Int else { return nil }
        
        self.number = number
        self.aired = aired
        self.completed = completed
        
        if let jsonEpisodes = json["episodes"] as? [RawJSON] {
            episodes = initEach(jsonEpisodes)
        }
        else {
            episodes = []
        }
    }
}

public struct TraktEpisodeWatchedProgress: TraktProtocol {
    // Extended: Min
    /// Season number
    public let number: Int
    /// Has this episode been watched
    public let completed: Bool
    /// When the last episode was watched
    public let lastWatchedAt: Date?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let number = json["number"] as? Int,
            let completed = json["completed"] as? Bool else { return nil }
        
        self.number = number
        self.completed = completed
        self.lastWatchedAt = Date.dateFromString(json["last_watched_at"])
    }
}
