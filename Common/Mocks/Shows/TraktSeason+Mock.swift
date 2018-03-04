//
//  TraktSeason+Mock.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/3/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktSeason {
    static func createMock(season: Int,
                           ids: SeasonId,
                           rating: Double? = nil,
                           votes: Int? = nil,
                           episodeCount: Int? = nil,
                           airedEpisodes: Int? = nil,
                           title: String? = nil,
                           overview: String? = nil,
                           firstAired: Date? = nil,
                           episodes: [TraktEpisode]? = nil,
                           decoder: JSONDecoder) throws -> TraktSeason {
        var jsonDictionary: [String: Any] = [:]
        jsonDictionary[CodingKeys.number.rawValue] = season
        jsonDictionary[CodingKeys.ids.rawValue] = try ids.asDictionary()

        jsonDictionary[CodingKeys.rating.rawValue] = rating
        jsonDictionary[CodingKeys.votes.rawValue] = votes
        jsonDictionary[CodingKeys.episodeCount.rawValue] = episodeCount
        jsonDictionary[CodingKeys.airedEpisodes.rawValue] = airedEpisodes
        jsonDictionary[CodingKeys.title.rawValue] = title
        jsonDictionary[CodingKeys.overview.rawValue] = overview
        jsonDictionary[CodingKeys.firstAired.rawValue] = firstAired

        jsonDictionary[CodingKeys.episodes.rawValue] = episodes

        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return try decoder.decode(self, from: data)
    }
}
