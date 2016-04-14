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
    public let lastWatchedAt: NSDate
    
    // Initialize
    public init(json: RawJSON) {
        number = json["number"] as? Int ?? 0
        plays = json["plays"] as? Int ?? 0
        lastWatchedAt = NSDate.dateFromString(json["last_watched_at"] as? String) ?? NSDate()
    }
    
    public init?(json: RawJSON?) {
        guard let json = json,
            number = json["number"] as? Int,
            plays = json["plays"] as? Int,
            lastWatchedAt = NSDate.dateFromString(json["last_watched_at"] as? String) else { return nil }
        
        self.number = number
        self.plays = plays
        self.lastWatchedAt = lastWatchedAt
    }
}
