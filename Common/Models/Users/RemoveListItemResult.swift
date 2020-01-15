//
//  RemoveListItemResult.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 8/11/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveListItemResult: Codable {
    let deleted: Added
    let notFound: NotFound

    public struct Added: Codable {
        let movies: Int
        let shows: Int
        let seasons: Int
        let episodes: Int
        let people: Int
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
