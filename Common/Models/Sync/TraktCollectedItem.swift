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
        case lastCollectedAt = "last_collected_at" // Can be last_collected_at / collected_at though
        case movieLastCollectAt = "collected_at"
        case movie
        case show
        case seasons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            self.lastCollectedAt = try container.decode(Date.self, forKey: .lastCollectedAt)
        } catch {
            self.lastCollectedAt = try container.decode(Date.self, forKey: .movieLastCollectAt)
        }
        movie = try container.decodeIfPresent(TraktMovie.self, forKey: .movie)
        show = try container.decodeIfPresent(TraktShow.self, forKey: .show)
        seasons = try container.decodeIfPresent([TraktCollectedSeason].self, forKey: .seasons)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if movie != nil {
            try container.encode(lastCollectedAt, forKey: .movieLastCollectAt)
        } else {
            try container.encode(lastCollectedAt, forKey: .lastCollectedAt)
        }
        try container.encodeIfPresent(movie, forKey: .movie)
        try container.encodeIfPresent(show, forKey: .show)
        try container.encodeIfPresent(seasons, forKey: .seasons)
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
