//
//  TraktSeason.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktSeason: TraktProtocol {
    // Extended: Min
    public let number: Int
    public let ids: ID
    public let rating: Double
    public let votes: Int
    public let episodeCount: Int
    public let airedEpisodes: Int
    public let overview: String
    public let firstAired: Date
    
    // Extended: Full
    public let episodes: [TraktEpisode]
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            number = json["number"] as? Int,
            ids = ID(json: json["ids"] as? RawJSON),
            rating = json["rating"] as? Double,
            votes = json["votes"] as? Int,
            episodeCount = json["episode_count"] as? Int,
            airedEpisodes = json["aired_episodes"] as? Int,
            firstAired = Date.dateFromString(json["first_aired"] as? String) else { return nil }
        
        self.number = number
        self.ids    = ids
        self.rating = rating
        self.votes = votes
        self.episodeCount = episodeCount
        self.airedEpisodes = airedEpisodes
        self.overview = json["overview"] as? String ?? ""
        self.firstAired = firstAired
        
        self.episodes = initEach(json["episodes"] as? [RawJSON] ?? [])
    }
}
