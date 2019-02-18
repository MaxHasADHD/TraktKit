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
    public let lastUpdatedAt: Date
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var seasons: [TraktCollectedSeason]?
    
    enum MovieCodingKeys: String, CodingKey {
        case lastCollectedAt = "collected_at"
        case lastUpdatedAt = "updated_at"
        case movie
    }
    
    enum ShowCodingKeys: String, CodingKey {
        case lastCollectedAt = "last_collected_at"
        case lastUpdatedAt = "last_updated_at"
        case show
        case seasons
    }

    public init(from decoder: Decoder) throws {
        if let movieContainer = try? decoder.container(keyedBy: MovieCodingKeys.self), !movieContainer.allKeys.isEmpty {
            movie = try movieContainer.decodeIfPresent(TraktMovie.self, forKey: .movie)
            lastUpdatedAt = try movieContainer.decode(Date.self, forKey: .lastUpdatedAt)
            lastCollectedAt = try movieContainer.decode(Date.self, forKey: .lastCollectedAt)
        } else {
            let showContainer = try decoder.container(keyedBy: ShowCodingKeys.self)
            show = try showContainer.decodeIfPresent(TraktShow.self, forKey: .show)
            seasons = try showContainer.decodeIfPresent([TraktCollectedSeason].self, forKey: .seasons)
            lastUpdatedAt = try showContainer.decode(Date.self, forKey: .lastUpdatedAt)
            lastCollectedAt = try showContainer.decode(Date.self, forKey: .lastCollectedAt)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let movie = movie {
            var container = encoder.container(keyedBy: MovieCodingKeys.self)
            try container.encodeIfPresent(movie, forKey: .movie)
            try container.encode(lastCollectedAt, forKey: .lastCollectedAt)
            try container.encode(lastUpdatedAt, forKey: .lastUpdatedAt)
        } else {
            var container = encoder.container(keyedBy: ShowCodingKeys.self)
            try container.encodeIfPresent(show, forKey: .show)
            try container.encodeIfPresent(seasons, forKey: .seasons)
            try container.encode(lastCollectedAt, forKey: .lastCollectedAt)
            try container.encode(lastUpdatedAt, forKey: .lastUpdatedAt)
        }
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
