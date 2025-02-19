//
//  TraktAnticipatedMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/23/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktAnticipatedMovie: TraktObject {
    // Extended: Min
    public let listCount: Int
    public let movie: TraktMovie
    
    enum CodingKeys: String, CodingKey {
        case listCount = "list_count"
        case movie
    }
}
