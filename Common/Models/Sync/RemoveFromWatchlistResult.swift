//
//  RemoveFromWatchlistResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveFromWatchlistResult: Codable {
    let deleted: Deleted
    let notFound: NotFound

    public struct Deleted: Codable {
        let movies: Int
        let shows: Int
        let seasons: Int
        let episodes: Int
    }

    public struct NotFoundItem: Codable {
        let ids: ID
    }

    public struct NotFound: Codable {
        let movies: [NotFoundItem]
        let shows: [NotFoundItem]
        let seasons: [NotFoundItem]
        let episodes: [NotFoundItem]
    }


    enum CodingKeys: String, CodingKey {
        case deleted
        case notFound = "not_found"
    }
}
