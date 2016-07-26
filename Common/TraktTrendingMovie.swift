//
//  TraktTrendingMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktTrendingMovie: TraktProtocol {
    // Extended: Min
    public let watchers: Int
    public let movie: TraktMovie
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let watchers = json["watchers"] as? Int,
            let movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
        
        self.watchers = watchers
        self.movie = movie
    }
}
