//
//  TraktCollectedItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/21/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktCollectedItem: TraktProtocol {
    
    public var lastCollectedAt: Date
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var seasons: [TraktCollectedSeason]?
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let dateString = json["collected_at"] ?? json["last_collected_at"],
            let lastCollectedAt = Date.dateFromString(dateString) else { return nil }
        
        self.lastCollectedAt = lastCollectedAt
        
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
        self.seasons = (json["seasons"] as? [RawJSON])?.flatMap { TraktCollectedSeason(json: $0) }
    }
}

public struct TraktCollectedSeason: TraktProtocol {
    
    /// Season number
    public var number: NSNumber
    public var episodes: [TraktCollectedEpisode]
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let number = json["number"] as? NSNumber else { return nil }
        
        self.number = number
        self.episodes = (json["episodes"] as? [RawJSON])?.flatMap { TraktCollectedEpisode(json: $0) } ?? []
    }
}

public struct TraktCollectedEpisode: TraktProtocol {
    
    public var number: NSNumber
    public var collectedAt: Date
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let number = json["number"] as? NSNumber,
            let collectedAt = Date.dateFromString(json["collectedAt"]) else { return nil }
        
        self.number = number
        self.collectedAt = collectedAt
    }
}
