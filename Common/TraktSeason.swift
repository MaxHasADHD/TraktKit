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
    public let ids: SeasonId
    public let rating: Double
    public let votes: Int
    public let episodeCount: Int
    public let airedEpisodes: Int
    public let overview: String?
    public let firstAired: Date?
    
    // Extended: Full
    public let episodes: [TraktEpisode]
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let number = json["number"] as? Int,
            let ids = SeasonId(json: json["ids"] as? RawJSON),
            let rating = json["rating"] as? Double,
            let votes = json["votes"] as? Int,
            let episodeCount = json["episode_count"] as? Int,
            let airedEpisodes = json["aired_episodes"] as? Int else { return nil }
        
        self.number = number
        self.ids    = ids
        self.rating = rating
        self.votes = votes
        self.episodeCount = episodeCount
        self.airedEpisodes = airedEpisodes
        self.overview = json["overview"] as? String
        self.firstAired = Date.dateFromString(json["first_aired"])
        
        self.episodes = initEach(json["episodes"] as? [RawJSON] ?? [])
    }
}
