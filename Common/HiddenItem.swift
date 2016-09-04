//
//  HiddenItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 9/3/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct HiddenItem: TraktProtocol {
    public let hiddenAt: Date
    public let type: String
    
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let season: TraktSeason?
    
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let hiddenAt = Date.dateFromString(json["hidden_at"]),
            let type = json["type"] as? String else { return nil }
        
        self.hiddenAt = hiddenAt
        self.type = type
        
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
        self.season = TraktSeason(json: json["season"] as? RawJSON)
    }
}
