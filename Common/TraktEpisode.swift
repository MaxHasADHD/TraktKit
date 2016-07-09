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
    public let title: String
    public let ids: ID
    
    // Extended: Full
    public let overview: String?
    public let rating: Double?
    public let votes: Int?
    public let firstAired: Date?
    public let updatedAt: Date?
    public let availableTranslations: [RawJSON]?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            season = json["season"] as? Int,
            number = json["number"] as? Int,
            title = json["title"] as? String,
            ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        // Min
        self.season = season
        self.number = number
        self.title  = title
        self.ids    = ids
        
        // Full
        self.overview   = json["overview"] as? String
        self.rating     = json["rating"] as? Double
        self.votes      = json["votes"] as? Int
        self.firstAired = Date.dateFromString(json["first_aired"] as? String)
        self.updatedAt  = Date.dateFromString(json["updated_at"] as? String)
        self.availableTranslations = []
    }
}
