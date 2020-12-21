//
//  RemoveListItemResult.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 8/11/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveListItemResult: Codable, Hashable {
    public let deleted: Deleted
    public let notFound: NotFound

    public struct Deleted: Codable, Hashable {
        public let movies: Int
        public let shows: Int
        public let seasons: Int
        public let episodes: Int
        public let people: Int
    }
    
    public struct NotFound: Codable, Hashable {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
        public let episodes: [NotFoundIds]
        public let people: [NotFoundIds]
    }
    
    enum CodingKeys: String, CodingKey {
        case deleted
        case notFound = "not_found"
    }
}
