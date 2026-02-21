//
//  TraktMostMovie.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/24/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktMostMovie: TraktObject {

    // Extended: Min
    public let watcherCount: Int
    public let playCount: Int
    public let collectedCount: Int
    public let movie: TraktMovie

    enum CodingKeys: String, CodingKey {
        case watcherCount = "watcher_count"
        case playCount = "play_count"
        case collectedCount = "collected_count"
        case movie
    }
}
