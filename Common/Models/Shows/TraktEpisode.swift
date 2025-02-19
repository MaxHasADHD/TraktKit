//
//  TraktEpisode.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktEpisode: TraktObject {
    
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
    /// When getting full extended info, the `episodeType` field can have a value of `standard`, `series_premiere` (season 1, episode 1), `season_premiere` (episode 1), `mid_season_finale`,` mid_season_premiere` (the next episode after the mid season finale), `season_finale`, or `series_finale` (last episode to air for an ended show).
    public let episodeType: String?

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
        case episodeType = "episode_type"
    }
    
    public init(
        season: Int,
        number: Int,
        title: String? = nil,
        ids: EpisodeId,
        overview: String? = nil,
        rating: Double? = nil,
        votes: Int? = nil,
        firstAired: Date? = nil,
        updatedAt: Date? = nil,
        availableTranslations: [String]? = nil,
        absoluteNumber: Int? = nil,
        runtime: Int? = nil,
        commentCount: Int? = nil,
        episodeType: String? = nil
    ) {
        self.season = season
        self.number = number
        self.title = title
        self.ids = ids
        self.overview = overview
        self.rating = rating
        self.votes = votes
        self.firstAired = firstAired
        self.updatedAt = updatedAt
        self.availableTranslations = availableTranslations
        self.absoluteNumber = absoluteNumber
        self.commentCount = commentCount
        self.runtime = runtime
        self.episodeType = episodeType
    }
}
