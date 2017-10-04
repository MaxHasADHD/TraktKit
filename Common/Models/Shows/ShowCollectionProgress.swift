//
//  ShowCollectionProgress.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ShowCollectionProgress: Codable {
    
    public let aired: Int
    public let completed: Int
    public let lastCollectedAt: Date
    public let seasons: [CollectedSeason]
    public let hiddenSeasons: [TraktSeason]
    public let nextEpisode: TraktEpisode?
    
    enum CodingKeys: String, CodingKey {
        case aired
        case completed
        case lastCollectedAt = "last_collected_at"
        case seasons
        case hiddenSeasons = "hidden_seasons"
        case nextEpisode = "next_episode"
    }
    
    public struct CollectedSeason: Codable {
        let number: Int
        let aired: Int
        let completed: Int
        let episodes: [CollectedEpisode]
    }
    
    public struct CollectedEpisode: Codable {
        let number: Int
        let completed: Bool
        let collectedAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case number
            case completed
            case collectedAt = "collected_at"
        }
    }
}
