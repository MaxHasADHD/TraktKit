//
//  HiddenItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 9/3/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct HiddenItem: Codable {
    public let hiddenAt: Date
    public let type: String
    
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let season: TraktSeason?
    
    enum CodingKeys: String, CodingKey {
        case hiddenAt = "hidden_at"
        case type
        case movie
        case show
        case season
    }
}
