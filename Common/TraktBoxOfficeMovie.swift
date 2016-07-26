//
//  TraktBoxOfficeMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 5/1/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktBoxOfficeMovie: TraktProtocol {
    // Extended: Min
    public let revenue: Int
    public let movie: TraktMovie
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let revenue = json["revenue"] as? Int,
            let movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
        
        self.revenue = revenue
        self.movie = movie
    }
}
