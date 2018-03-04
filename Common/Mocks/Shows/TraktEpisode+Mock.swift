//
//  TraktEpisode+Mock.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/3/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktEpisode {
    static func createMock(title: String?,
                           season: Int,
                           episode: Int,
                           ids: EpisodeId,
                           overview: String? = nil,
                           rating: Double? = nil,
                           votes: Int? = nil,
                           firstAired: Date? = nil,
                           updatedAt: Date? = nil,
                           availableTranslations: [String]? = nil,
                           decoder: JSONDecoder) throws -> TraktEpisode {
        var jsonDictionary: [String: Any] = [:]
        jsonDictionary[CodingKeys.title.rawValue] = title
        jsonDictionary[CodingKeys.season.rawValue] = season
        jsonDictionary[CodingKeys.number.rawValue] = episode
        jsonDictionary[CodingKeys.ids.rawValue] = try ids.asDictionary()

        jsonDictionary[CodingKeys.overview.rawValue] = overview
        jsonDictionary[CodingKeys.rating.rawValue] = rating
        jsonDictionary[CodingKeys.votes.rawValue] = votes
        jsonDictionary[CodingKeys.firstAired.rawValue] = firstAired
        jsonDictionary[CodingKeys.updatedAt.rawValue] = updatedAt
        jsonDictionary[CodingKeys.availableTranslations.rawValue] = availableTranslations

        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return try decoder.decode(self, from: data)
    }
}
