//
//  TraktWatchedEpisodes.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedEpisodes: TraktObject {
    // Extended: Min
    public let number: Int
    public let plays: Int
    public let lastWatchedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case number
        case plays
        case lastWatchedAt = "last_watched_at"
    }
}
