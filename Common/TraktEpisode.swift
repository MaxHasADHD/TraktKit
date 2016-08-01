//
//  TraktEpisode.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktEpisode: TraktProtocol {
    // Extended: Min
    public let season: Int
    public let number: Int
    public let title: String? // Might be missing, TBA episode
    public let ids: EpisodeId
    
    // Extended: Full
    public let overview: String?
    public let rating: Double?
    public let votes: Int?
    public let firstAired: Date?
    public let updatedAt: Date?
    public let availableTranslations: [RawJSON]?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let season = json["season"] as? Int,
            let number = json["number"] as? Int,
            let ids = EpisodeId(json: json["ids"] as? RawJSON) else { return nil }
        
        // Min
        self.season = season
        self.number = number
        self.title  = json["title"] as? String
        self.ids    = ids
        
        // Full
        self.overview   = json["overview"] as? String
        self.rating     = json["rating"] as? Double
        self.votes      = json["votes"] as? Int
        self.firstAired = Date.dateFromString(json["first_aired"] as? String)
        self.updatedAt  = Date.dateFromString(json["updated_at"] as? String)
        self.availableTranslations = []
        
        // Extended: Images
        images = TraktImages(json: json["images"] as? RawJSON)
    }
}
