//
//  AddToHistoryResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 12/7/20.
//  Copyright © 2020 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct NotFoundIds: Codable, Hashable {
    public let trakt: Int?
    public let slug: String?
    public let tvdb: Int?
    public let imdb: String?
    public let tmdb: Int?
    public let tvRage: Int?
    
    enum IDsCodingKeys: String, CodingKey {
        case trakt
        case slug
        case tvdb
        case imdb
        case tmdb
        case tvRage = "tvrage"
    }
    
    enum CodingKeys: String, CodingKey {
        case ids
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idsContainer = try container.nestedContainer(keyedBy: IDsCodingKeys.self, forKey: .ids)
        self.trakt = try idsContainer.decodeIfPresent(Int.self, forKey: .trakt)
        self.slug = try idsContainer.decodeIfPresent(String.self, forKey: .slug)
        self.tvdb = try idsContainer.decodeIfPresent(Int.self, forKey: .tvdb)
        self.imdb = try idsContainer.decodeIfPresent(String.self, forKey: .imdb)
        self.tmdb = try idsContainer.decodeIfPresent(Int.self, forKey: .tmdb)
        self.tvRage = try idsContainer.decodeIfPresent(Int.self, forKey: .tvRage)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var idsContainer = container.nestedContainer(keyedBy: IDsCodingKeys.self, forKey: .ids)
        try idsContainer.encodeIfPresent(trakt, forKey: .trakt)
        try idsContainer.encodeIfPresent(slug, forKey: .slug)
        try idsContainer.encodeIfPresent(tvdb, forKey: .tvdb)
        try idsContainer.encodeIfPresent(imdb, forKey: .imdb)
        try idsContainer.encodeIfPresent(tmdb, forKey: .tmdb)
        try idsContainer.encodeIfPresent(tvRage, forKey: .tvRage)
    }
}

public struct AddToHistoryResult: Codable, Hashable {
    public let added: Added
    public let notFound: NotFound
    
    public struct Added: Codable, Hashable {
        public let movies: Int
        public let episodes: Int
    }
    
    public struct NotFound: Codable, Hashable {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
        public let episodes: [NotFoundIds]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
        case notFound = "not_found"
    }
}

public struct RemoveFromHistoryResult: Codable, Hashable {
    public let deleted: Deleted
    public let notFound: NotFound
    
    public struct Deleted: Codable, Hashable {
        public let movies: Int
        public let episodes: Int
    }
    
    public struct NotFound: Codable, Hashable {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
        public let episodes: [NotFoundIds]
        /// Array of history ids.
        public let ids: [Int]?
    }
    
    enum CodingKeys: String, CodingKey {
        case deleted
        case notFound = "not_found"
    }
}
