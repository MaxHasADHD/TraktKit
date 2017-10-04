//
//  TraktSeason.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktSeason: Codable {
    
    // Extended: Min
    public let number: Int
    public let ids: SeasonId
    
    // Extended: Full
    public let rating: Double?
    public let votes: Int?
    public let episodeCount: Int?
    public let airedEpisodes: Int?
    public let title: String?
    public let overview: String?
    public let firstAired: Date?
    
    // Extended: Episodes
    public let episodes: [TraktEpisode]?
    
    enum CodingKeys: String, CodingKey {
        case number
        case ids
        
        case rating
        case votes
        case episodeCount = "episode_count"
        case airedEpisodes = "aired_episodes"
        case title
        case overview
        case firstAired = "first_aired"
        
        case episodes
    }
}
