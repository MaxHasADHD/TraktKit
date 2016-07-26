//
//  TraktWatchedSeason.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedSeason: TraktProtocol {
    // Extended: Min
    public let number: Int // Season number
    public let episodes: [TraktWatchedEpisodes]
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let number = json["number"] as? Int else { return nil }
        
        self.number = number
        
        var tempEpisodes: [TraktWatchedEpisodes] = []
        let jsonEpisodes = json["episodes"] as? [RawJSON] ?? []
        for jsonEpisode in jsonEpisodes {
            tempEpisodes.append(TraktWatchedEpisodes(json: jsonEpisode))
        }
        episodes = tempEpisodes
    }
}
