//
//  RemoveFromWatchlistResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveFromWatchlistResult: Codable, Hashable {
    let deleted: Deleted
//    let notFound: NotFound

    public struct Deleted: Codable, Hashable {
        let movies: Int
        let shows: Int
        let seasons: Int
        let episodes: Int
    }
    
    public struct NotFound: Codable, Hashable {
        let movies: [ID]
        let shows: [ID]
        let seasons: [ID]
        let episodes: [ID]
    }
    
    enum CodingKeys: String, CodingKey {
        case deleted
//        case notFound = "not_found"
    }
}
