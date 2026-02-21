//
//  TraktRating.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/15/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktRating: TraktObject {
    public var ratedAt: Date
    public var rating: Int
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var season: TraktSeason?
    public var episode: TraktEpisode?
    
    enum CodingKeys: String, CodingKey {
        case ratedAt = "rated_at"
        case rating
        case movie
        case show
        case season
        case episode
    }
}
