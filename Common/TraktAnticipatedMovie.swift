//
//  TraktAnticipatedMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/23/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktAnticipatedMovie: TraktProtocol {
    // Extended: Min
    public let listCount: Int
    public let movie: TraktMovie
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let listCount = json["list_count"] as? Int,
            let movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
        
        self.listCount = listCount
        self.movie = movie
    }
}
