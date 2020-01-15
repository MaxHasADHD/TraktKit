//
//  RemoveFromCollectionResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveFromCollectionResult: Codable {
    public let deleted: deleted
    public let notFound: NotFound

    public struct deleted: Codable {
        let movies: Int
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
