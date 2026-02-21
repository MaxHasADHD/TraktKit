//
//  TraktListItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/22/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktListItem: TraktObject {
    public let rank: Int
    public let id: Int
    public let listedAt: Date
    public let notes: String?
    public let type: String
    public var show: TraktShow? = nil
    public var season: TraktSeason? = nil
    public var episode: TraktEpisode? = nil
    public var movie: TraktMovie? = nil
    public var person: Person? = nil
    
    enum CodingKeys: String, CodingKey {
        case rank
        case id
        case listedAt = "listed_at"
        case notes
        case type
        case show
        case season
        case episode
        case movie
        case person
    }
}
