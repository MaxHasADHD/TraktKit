//
//  ListItemPostResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/10/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ListItemPostResult: TraktObject {
    public let added: ObjectCount
    public let existing: ObjectCount
    public let notFound: NotFound

    public struct ObjectCount: TraktObject {
        public let movies: Int
        public let shows: Int
        public let seasons: Int
        public let episodes: Int
        public let people: Int
    }
    
    public struct NotFound: TraktObject {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
        public let episodes: [NotFoundIds]
        public let people: [NotFoundIds]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
        case existing
        case notFound = "not_found"
    }
}

public struct WatchlistItemPostResult: TraktObject {
    public let added: ObjectCount
    public let existing: ObjectCount
    public let notFound: NotFound
    public let list: List

    public struct ObjectCount: TraktObject {
        public let movies: Int
        public let shows: Int
        public let seasons: Int
        public let episodes: Int
    }
    
    public struct NotFound: TraktObject {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
        public let episodes: [NotFoundIds]
    }

    public struct List: TraktObject {
        public let updatedAt: Date
        public let itemCount: Int

        enum CodingKeys: String, CodingKey {
            case updatedAt = "updated_at"
            case itemCount = "item_count"
        }
    }

    enum CodingKeys: String, CodingKey {
        case added
        case existing
        case notFound = "not_found"
        case list
    }
}

