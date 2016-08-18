//
//  TraktWatchedEpisodes.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedEpisodes: TraktProtocol {
    // Extended: Min
    public let number: Int // Episode number
    public let plays: Int // Number of plays
    public let lastWatchedAt: Date
    
    // Initialize
    public init(json: RawJSON) {
        number = json["number"] as? Int ?? 0
        plays = json["plays"] as? Int ?? 0
        lastWatchedAt = Date.dateFromString(json["last_watched_at"]) ?? Date()
    }
    
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let number = json["number"] as? Int,
            let plays = json["plays"] as? Int,
            let lastWatchedAt = Date.dateFromString(json["last_watched_at"]) else { return nil }
        
        self.number = number
        self.plays = plays
        self.lastWatchedAt = lastWatchedAt
    }
}
