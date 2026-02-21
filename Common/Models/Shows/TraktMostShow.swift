//
//  TraktMostShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Used for most played, watched, and collected shows
public struct TraktMostShow: TraktObject {
    
    // Extended: Min
    public let watcherCount: Int
    public let playCount: Int
    public let collectedCount: Int
    public let collectorCount: Int
    public let show: TraktShow
    
    enum CodingKeys: String, CodingKey {
        case watcherCount = "watcher_count"
        case playCount = "play_count"
        case collectedCount = "collected_count"
        case collectorCount = "collector_count"
        case show
    }
}
