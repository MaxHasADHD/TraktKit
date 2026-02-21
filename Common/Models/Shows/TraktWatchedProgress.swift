//
//  TraktWatchedProgress.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/31/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Watched progress. Shows/Progress/Watched
public struct TraktShowWatchedProgress: TraktObject {
    
    // Extended: Min
    /// Number of episodes that have aired
    public let aired: Int
    /// Number of episodes that have been watched
    public let completed: Int
    /// When the last episode was watched
    public let lastWatchedAt: Date?
    public let seasons: [TraktSeasonWatchedProgress]
    public let nextEpisode: TraktEpisode?
    
    enum CodingKeys: String, CodingKey {
        case aired
        case completed
        case lastWatchedAt = "last_watched_at"
        case seasons
        case nextEpisode = "next_episode"
    }
}

public struct TraktSeasonWatchedProgress: TraktObject {
    
    // Extended: Min
    /// Season number
    public let number: Int
    /// Number of episodes that have aired
    public let aired: Int
    /// Number of episodes that have been watched
    public let completed: Int
    public let episodes: [TraktEpisodeWatchedProgress]
}

public struct TraktEpisodeWatchedProgress: TraktObject {
    
    // Extended: Min
    /// Season number
    public let number: Int
    /// Has this episode been watched
    public let completed: Bool
    /// When the last episode was watched
    public let lastWatchedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case number
        case completed
        case lastWatchedAt = "last_watched_at"
    }
}
