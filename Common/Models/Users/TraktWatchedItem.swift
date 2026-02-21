//
//  TraktWatchedItem.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/23/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedItem: TraktObject {
    public let plays: Int
    public let lastWatchedAt: Date
    public let lastUpdatedAt: Date
    public var show: TraktShow? = nil
    public var seasons: [TraktWatchedSeason]? = nil
    public var movie: TraktMovie? = nil

    enum CodingKeys: String, CodingKey {
        case plays
        case lastWatchedAt = "last_watched_at"
        case lastUpdatedAt = "last_updated_at"
        case show
        case seasons
        case movie
    }
}
