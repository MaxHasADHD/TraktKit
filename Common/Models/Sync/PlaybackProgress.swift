//
//  PlaybackProgress.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct PlaybackProgress: TraktObject {
    public let progress: Float
    public let pausedAt: Date
    public let id: Int
    public let type: String
    public let movie: TraktMovie?
    public let episode: TraktEpisode?
    public let show: TraktShow?
    
    enum CodingKeys: String, CodingKey {
        case progress
        case pausedAt = "paused_at"
        case id
        case type
        case movie
        case episode
        case show
    }
}
