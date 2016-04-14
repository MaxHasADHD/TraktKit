//
//  TraktMostShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

// Used for most played, watched, and collected shows
public struct TraktMostShow: TraktProtocol {
    // Extended: Min
    public let watcherCount: Int
    public let playCount: Int
    public let collectedCount: Int
    public let collectorCount: Int
    public let show: TraktShow
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            watcherCount = json["watcher_count"] as? Int,
            playCount = json["play_count"] as? Int,
            collectedCount = json["collected_count"] as? Int,
            collectorCount = json["collector_count"] as? Int,
            show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.watcherCount = watcherCount
        self.playCount = playCount
        self.collectedCount = collectedCount
        self.collectorCount = collectorCount
        self.show = show
    }
}
