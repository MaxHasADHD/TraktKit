//
//  TraktRating.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/15/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktRating: TraktProtocol {
    
    public var ratedAt: Date
    public var rating: NSNumber
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var season: TraktSeason?
    public var episode: TraktEpisode?
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let ratedAt = Date.dateFromString(json["rated_at"]),
            let rating = json["rating"] as? NSNumber else { return nil }
        
        self.ratedAt = ratedAt
        self.rating = rating
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
        self.season = TraktSeason(json: json["season"] as? RawJSON)
        self.episode = TraktEpisode(json: json["episode"] as? RawJSON)
    }
}
