//
//  TraktWatchedMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedMovie: TraktObject {
    // Extended: Min
    public let plays: Int // Total number of plays
    public let lastWatchedAt: Date
    public let lastUpdatedAt: Date
    public let movie: TraktMovie
    
    enum CodingKeys: String, CodingKey {
        case plays
        case lastWatchedAt = "last_watched_at"
        case lastUpdatedAt = "last_updated_at"
        case movie
    }
}
