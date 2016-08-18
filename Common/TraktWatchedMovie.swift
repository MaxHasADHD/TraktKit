//
//  TraktWatchedMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedMovie: TraktProtocol {
    // Extended: Min
    public let plays: Int // Total number of plays
    public let lastWatchedAt: Date
    public let movie: TraktMovie
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let plays = json["plays"] as? Int,
            let lastWatchedAt = Date.dateFromString(json["last_watched_at"]),
            let movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
        
        self.plays = plays
        self.lastWatchedAt = lastWatchedAt
        self.movie = movie
    }
}
