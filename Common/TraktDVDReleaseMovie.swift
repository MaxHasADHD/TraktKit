//
//  TraktDVDReleaseMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/26/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktDVDReleaseMovie: TraktProtocol {
    // Extended: Min
    public let released: Date
    public let movie: TraktMovie
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let released = Date.dateFromString(json["released"]),
            let movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
        
        self.released = released
        self.movie = movie
    }
}
