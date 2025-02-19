//
//  TraktSeason.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktSeason: TraktObject {
    
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
    public let updatedAt: Date?
    public let network: String?
    
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
        case updatedAt = "updated_at"
        case network
        
        case episodes
    }
    
    public init(number: Int, ids: SeasonId, rating: Double? = nil, votes: Int? = nil, episodeCount: Int? = nil, airedEpisodes: Int? = nil, title: String? = nil, overview: String? = nil, firstAired: Date? = nil, updatedAt: Date? = nil, network: String? = nil, episodes: [TraktEpisode]? = nil) {
        self.number = number
        self.ids = ids
        self.rating = rating
        self.votes = votes
        self.episodeCount = episodeCount
        self.airedEpisodes = airedEpisodes
        self.title = title
        self.overview = overview
        self.firstAired = firstAired
        self.updatedAt = updatedAt
        self.network = network
        self.episodes = episodes
    }
}
