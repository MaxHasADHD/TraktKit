//
//  TraktWatchedShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedShow: TraktProtocol {
    // Extended: Min
    public let plays: Int // Total number of plays
    public let lastWatchedAt: Date
    public let show: TraktShow
    public let seasons: [TraktWatchedSeason]
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let plays = json["plays"] as? Int,
            let lastWatchedAt = Date.dateFromString(json["last_watched_at"]),
            let show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.plays          = plays
        self.lastWatchedAt  = lastWatchedAt
        self.show           = show
        
        var tempSeasons: [TraktWatchedSeason] = []
        let jsonSeasons = json["seasons"] as? [RawJSON] ?? []
        for jsonSeason in jsonSeasons {
            guard
                let season = TraktWatchedSeason(json: jsonSeason) else { continue }
            tempSeasons.append(season)
        }
        seasons = tempSeasons
    }
}
