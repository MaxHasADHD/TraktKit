//
//  TraktWatchedShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedShow: TraktObject {
    
    // Extended: Min

    public let plays: Int
    public let lastWatchedAt: Date
    public let lastUpdatedAt: Date
    public let resetAt: Date?
    public let show: TraktShow
    /// nil if you use `?extended=noseasons`
    public let seasons: [TraktWatchedSeason]?
    
    enum CodingKeys: String, CodingKey {
        case plays
        case lastWatchedAt = "last_watched_at"
        case lastUpdatedAt = "last_updated_at"
        case resetAt = "reset_at"
        case show
        case seasons
    }
}
