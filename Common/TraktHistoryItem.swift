//
//  TraktHistoryItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/5/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktHistoryItem: TraktProtocol {
    
    public var id: NSNumber
    public var watchedAt: Date
    public var action: String
    public var type: String
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var season: TraktSeason?
    public var episode: TraktEpisode?
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let id = json["id"] as? NSNumber,
            let watchedAt = Date.dateFromString(json["watched_at"]),
            let action = json["action"] as? String,
            let type = json["type"] as? String else { return nil }
        
        self.id = id
        self.watchedAt = watchedAt
        self.action = action
        self.type = type
        
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
        self.season = TraktSeason(json: json["season"] as? RawJSON)
        self.episode = TraktEpisode(json: json["episode"] as? RawJSON)
    }
}
