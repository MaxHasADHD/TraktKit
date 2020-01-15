//
//  RemoveRatingsResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveRatingsResult: Codable {
    public let deleted: Deleted
    public let notFound: NotFound

    public struct Deleted: Codable {
        public let movies: Int
        public let shows: Int
        public let seasons: Int
        public let episodes: Int
    }

    public struct NotFoundItem: Codable {
        public let ids: ID
    }

    public struct NotFound: Codable {
        public let movies: [NotFoundItem]
        public let shows: [NotFoundItem]
        public let seasons: [NotFoundItem]
        public let episodes: [NotFoundItem]
    }

    enum CodingKeys: String, CodingKey {
        case deleted
        case notFound = "not_found"
    }
}
