//
//  TraktCollectedItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/21/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktCollectedItem: Codable {
    
    public var lastCollectedAt: Date
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var seasons: [TraktCollectedSeason]?
    
    enum CodingKeys: String, CodingKey {
        case lastCollectedAt = "collected_at" // Can be last_collected_at though :/
        case movie
        case show
        case seasons
    }
}

public struct TraktCollectedSeason: Codable {
    
    /// Season number
    public var number: Int
    public var episodes: [TraktCollectedEpisode]
}

public struct TraktCollectedEpisode: Codable {
    
    public var number: Int
    public var collectedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case number
        case collectedAt = "collected_at"
    }
}
