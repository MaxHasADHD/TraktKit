//
//  TraktWatchedShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedShow: Codable, Hashable {
    
    // Extended: Min
    public let plays: Int // Total number of plays
    public let lastWatchedAt: Date?
    public let lastUpdatedAt: Date?
    public let show: TraktShow
    public let seasons: [TraktWatchedSeason]?
    
    enum CodingKeys: String, CodingKey {
        case plays
        case lastWatchedAt = "last_watched_at"
        case lastUpdatedAt = "last_updated_at"
        case show
        case seasons
    }
    
    public init(plays: Int, lastWatchedAt: Date?, lastUpdatedAt: Date?, show: TraktShow, seasons: [TraktWatchedSeason]?) {
        self.plays = plays
        self.lastWatchedAt = lastWatchedAt
        self.lastUpdatedAt = lastUpdatedAt
        self.show = show
        self.seasons = seasons
    }
}
