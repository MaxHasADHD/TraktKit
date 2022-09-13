//
//  EpisodeResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct EpisodeResource {
    public let showId: CustomStringConvertible
    public let seasonNumber: Int
    public let episodeNumber: Int
    public let traktManager: TraktManager
    private let path: String
    
    init(showId: CustomStringConvertible, seasonNumber: Int, episodeNumber: Int, traktManager: TraktManager = .sharedManager) {
        self.showId = showId
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.traktManager = traktManager
        self.path = "shows/\(showId)/seasons/\(seasonNumber)/episodes/\(episodeNumber)"
    }
    
    public func summary() async throws -> Route<TraktEpisode> {
        try await traktManager.get(path)
    }
    
    public func comments() async throws -> Route<[Comment]> {
        try await traktManager.get(path + "/comments")
    }
    
    public func people() async throws -> Route<CastAndCrew<TVCastMember, TVCrewMember>> {
        try await traktManager.get(path + "/people")
    }
}
