//
//  TraktWatchedItem.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/23/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedItem: Codable {
    public let plays: Int
    public let lastWatchedAt: Date
    public var show: TraktShow? = nil
    public var seasons: [TraktWatchedSeason]? = nil
    public var movie: TraktMovie? = nil

    enum CodingKeys: String, CodingKey {
        case plays
        case lastWatchedAt = "last_watched_at"
        case show
        case seasons
        case movie
    }

    public struct TraktWatchedSeason: Codable {
        public let number: Int
        public let episodes: [TraktWatchedEpisode]?

        public struct TraktWatchedEpisode: Codable {
            public let number: Int
            public let plays: Int
            public let lastWatchedAt: Date

            enum CodingKeys: String, CodingKey {
                case number
                case plays
                case lastWatchedAt = "last_watched_at"
            }
        }
    }
}
