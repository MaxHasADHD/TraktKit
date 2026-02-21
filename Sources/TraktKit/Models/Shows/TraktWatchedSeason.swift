//
//  TraktWatchedSeason.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatchedSeason: TraktObject {
    
    // Extended: Min
    public let number: Int // Season number
    public let episodes: [TraktWatchedEpisodes]
}
