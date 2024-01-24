//
//  Structures.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/4/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public typealias RawJSON = [String: Any] // Dictionary

// MARK: - TV & Movies

public struct ID: Codable, Hashable {

    public let trakt: Int
    public let slug: String
    public let tvdb: Int?
    public let imdb: String?
    public let tmdb: Int?
    public let tvRage: Int?
    
    enum CodingKeys: String, CodingKey {
        case trakt
        case slug
        case tvdb
        case imdb
        case tmdb
        case tvRage = "tvrage"
    }
    
    public init(trakt: Int, slug: String, tvdb: Int? = nil, imdb: String? = nil, tmdb: Int? = nil, tvRage: Int? = nil) {
        self.trakt = trakt
        self.slug = slug
        self.tvdb = tvdb
        self.imdb = imdb
        self.tmdb = tmdb
        self.tvRage = tvRage
    }
}

public struct SeasonId: Codable, Hashable {
    
    public let trakt: Int
    public let tvdb: Int?
    public let tmdb: Int?
    public let tvRage: Int?
    
    enum CodingKeys: String, CodingKey {
        case trakt
        case tvdb
        case tmdb
        case tvRage = "tvrage"
    }
    
    public init(trakt: Int, tvdb: Int? = nil, tmdb: Int? = nil, tvRage: Int? = nil) {
        self.trakt = trakt
        self.tvdb = tvdb
        self.tmdb = tmdb
        self.tvRage = tvRage
    }
}

public struct EpisodeId: Codable, Hashable {
    public let trakt: Int
    public let tvdb: Int?
    public let imdb: String?
    public let tmdb: Int?
    public let tvRage: Int?
    
    enum CodingKeys: String, CodingKey {
        case trakt
        case tvdb
        case imdb
        case tmdb
        case tvRage = "tvrage"
    }
    
    public init(trakt: Int, tvdb: Int? = nil, imdb: String? = nil, tmdb: Int? = nil, tvRage: Int? = nil) {
        self.trakt = trakt
        self.tvdb = tvdb
        self.imdb = imdb
        self.tmdb = tmdb
        self.tvRage = tvRage
    }
}

public struct ListId: Codable, Hashable {
    public let trakt: Int
    public let slug: String
    
    enum CodingKeys: String, CodingKey {
        case trakt
        case slug
    }
    
    public init(trakt: Int, slug: String) {
        self.trakt = trakt
        self.slug = slug
    }
}

// MARK: - Stats

public struct TraktStats: Codable, Hashable {
    public let watchers: Int
    public let plays: Int
    public let collectors: Int
    public let collectedEpisodes: Int?
    public let comments: Int
    public let lists: Int
    public let votes: Int
    
    enum CodingKeys: String, CodingKey {
        case watchers
        case plays
        case collectors
        case collectedEpisodes = "collected_episodes"
        case comments
        case lists
        case votes
    }
}

// MARK: - Last Activities

public struct TraktLastActivities: Codable, Hashable {
    public let all: Date
    public let movies: TraktLastActivityMovies
    public let episodes: TraktLastActivityEpisodes
    public let shows: TraktLastActivityShows
    public let seasons: TraktLastActivitySeasons
    public let comments: TraktLastActivityComments
    public let lists: TraktLastActivityLists
}

public struct TraktLastActivityMovies: Codable, Hashable {
    public let watchedAt: Date
    public let collectedAt: Date
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    public let pausedAt: Date
    public let hiddenAt: Date
    
    enum CodingKeys: String, CodingKey {
        case watchedAt = "watched_at"
        case collectedAt = "collected_at"
        case ratedAt = "rated_at"
        case watchlistedAt = "watchlisted_at"
        case commentedAt = "commented_at"
        case pausedAt = "paused_at"
        case hiddenAt = "hidden_at"
    }
}

public struct TraktLastActivityEpisodes: Codable, Hashable {
    public let watchedAt: Date
    public let collectedAt: Date
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    public let pausedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case watchedAt = "watched_at"
        case collectedAt = "collected_at"
        case ratedAt = "rated_at"
        case watchlistedAt = "watchlisted_at"
        case commentedAt = "commented_at"
        case pausedAt = "paused_at"
    }
}

public struct TraktLastActivityShows: Codable, Hashable {
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    public let hiddenAt: Date
    
    enum CodingKeys: String, CodingKey {
        case ratedAt = "rated_at"
        case watchlistedAt = "watchlisted_at"
        case commentedAt = "commented_at"
        case hiddenAt = "hidden_at"
    }
}

public struct TraktLastActivitySeasons: Codable, Hashable {
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    public let hiddenAt: Date
    
    enum CodingKeys: String, CodingKey {
        case ratedAt = "rated_at"
        case watchlistedAt = "watchlisted_at"
        case commentedAt = "commented_at"
        case hiddenAt = "hidden_at"
    }
}

public struct TraktLastActivityComments: Codable, Hashable {
    public let likedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case likedAt = "liked_at"
    }
}

public struct TraktLastActivityLists: Codable, Hashable {
    public let likedAt: Date
    public let updatedAt: Date
    public let commentedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case likedAt = "liked_at"
        case updatedAt = "updated_at"
        case commentedAt = "commented_at"
    }
}
