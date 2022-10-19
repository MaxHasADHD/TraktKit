//
//  TraktEpisode.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktEpisode: Codable, Hashable {
    
    // Extended: Min
    public let season: Int
    public let number: Int
    public let title: String?
    public let ids: EpisodeId
    
    // Extended: Full
    public let overview: String?
    public let rating: Double?
    public let votes: Int?
    public let firstAired: Date?
    public let updatedAt: Date?
    public let availableTranslations: [String]?
    public let absoluteNumber: Int?
    public let runtime: Int?
    public let commentCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case season
        case number
        case title
        case ids
        
        case overview
        case rating
        case votes
        case firstAired = "first_aired"
        case updatedAt = "updated_at"
        case availableTranslations = "available_translations"
        case absoluteNumber = "number_abs"
        case runtime
        case commentCount = "comment_count"
    }
}
