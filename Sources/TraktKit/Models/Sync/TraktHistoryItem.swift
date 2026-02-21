//
//  TraktHistoryItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/5/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktHistoryItem: TraktObject {
    
    public var id: Int
    public var watchedAt: Date
    public var action: String
    public var type: String
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var season: TraktSeason?
    public var episode: TraktEpisode?
    
    enum CodingKeys: String, CodingKey {
        case id
        case watchedAt = "watched_at"
        case action
        case type
        case movie
        case show
        case season
        case episode
    }
}
