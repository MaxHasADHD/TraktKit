//
//  Structures.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/4/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public typealias RawJSON = [String: Any] // Dictionary

public protocol TraktProtocol {
    init?(json: RawJSON?) // Min data must be present not to fail
}

func initEach<T: TraktProtocol>(_ dictionaries: [RawJSON]) -> [T] {
    var array = [T]()
    for dictionary in dictionaries {
        if let object = T(json: dictionary) {
            array.append(object)
        }
    }
    
    return array
}

// MARK: - TV & Movies

public class ID: NSObject, TraktProtocol, NSCoding {
    public let trakt: Int
    public let slug: String
    public let tvdb: Int?
    public let imdb: String?
    public let tmdb: Int?
    public let tvRage: Int?
    
    // Initialize
    public required init?(json: RawJSON?) {
        guard
            let json = json,
            let traktID = json["trakt"] as? Int,
            let slugID = json["slug"] as? String else { return nil }
        
        trakt = traktID
        slug = slugID
        
        tvdb = json["tvdb"] as? Int
        imdb = json["imdb"] as? String
        tmdb = json["tmdb"] as? Int
        tvRage = json["tvrage"] as? Int
    }
    
    // MARK: NSCoding
    
    required public init?(coder aDecoder: NSCoder) {
        self.trakt = aDecoder.decodeInteger(forKey: "trakt")
        self.slug = aDecoder.decodeObject(forKey: "slug") as! String
        
        self.tvdb = aDecoder.decodeObject(forKey: "tvdb") as? Int
        self.imdb = aDecoder.decodeObject(forKey: "imdb") as? String
        self.tmdb = aDecoder.decodeObject(forKey: "tmdb") as? Int
        self.tvRage = aDecoder.decodeObject(forKey: "tvRage") as? Int
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.trakt, forKey: "trakt")
        aCoder.encode(self.slug, forKey: "slug")
        
        aCoder.encode(self.tvdb, forKey: "tvdb")
        aCoder.encode(self.imdb, forKey: "imdb")
        aCoder.encode(self.tmdb, forKey: "tmdb")
        aCoder.encode(self.tvRage, forKey: "tvRage")
    }
}

public struct SeasonId: TraktProtocol {
    public let trakt: Int
    public let tvdb: Int?
    public let tmdb: Int?
    public let tvRage: Int?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let traktID = json["trakt"] as? Int else { return nil }
        
        trakt = traktID
        tvdb = json["tvdb"] as? Int
        tmdb = json["tmdb"] as? Int
        tvRage = json["tvrage"] as? Int
    }
}

public class EpisodeId: NSObject, TraktProtocol, NSCoding {
    public let trakt: Int
    public let tvdb: Int?
    public let imdb: String?
    public let tmdb: Int?
    public let tvRage: Int?
    
    // Initialize
    public required init?(json: RawJSON?) {
        guard
            let json = json,
            let traktID = json["trakt"] as? Int else { return nil }
        
        trakt = traktID
        tvdb = json["tvdb"] as? Int
        imdb = json["imdb"] as? String
        tmdb = json["tmdb"] as? Int
        tvRage = json["tvrage"] as? Int
    }
    
    // MARK: NSCoding
    
    required public init?(coder aDecoder: NSCoder) {
        self.trakt = aDecoder.decodeInteger(forKey: "trakt")
        
        self.tvdb = aDecoder.decodeObject(forKey: "tvdb") as? Int
        self.imdb = aDecoder.decodeObject(forKey: "imdb") as? String
        self.tmdb = aDecoder.decodeObject(forKey: "tmdb") as? Int
        self.tvRage = aDecoder.decodeObject(forKey: "tvRage") as? Int
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.trakt, forKey: "trakt")
        
        aCoder.encode(self.tvdb, forKey: "tvdb")
        aCoder.encode(self.imdb, forKey: "imdb")
        aCoder.encode(self.tmdb, forKey: "tmdb")
        aCoder.encode(self.tvRage, forKey: "tvRage")
    }
}

// MARK: - Stats

public struct TraktStats: TraktProtocol {
    public let watchers: Int
    public let plays: Int
    public let collectors: Int
    public let collectedEpisodes: Int
    public let comments: Int
    public let lists: Int
    public let votes: Int
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let watchers = json["watchers"] as? Int,
            let plays = json["plays"] as? Int,
            let collectors = json["collectors"] as? Int,
            let comments = json["comments"] as? Int,
            let lists = json["lists"] as? Int,
            let votes = json["votes"] as? Int else { return nil }
        
        self.watchers = watchers
        self.plays = plays
        self.collectors = collectors
        self.collectedEpisodes = json["collected_episodes"] as? Int ?? 0 // Not included for movie stats
        self.comments = comments
        self.lists = lists
        self.votes = votes
    }
}

// MARK: - Last Activities

public struct TraktLastActivities: TraktProtocol {
    public let all: Date
    public let movies: TraktLastActivityMovies
    public let episodes: TraktLastActivityEpisodes
    public let shows: TraktLastActivityShows
    public let seasons: TraktLastActivitySeasons
    public let comments: TraktLastActivityComments
    public let lists: TraktLastActivityLists
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let allJSON = json["all"],
            let all = Date.dateFromString(allJSON),
            let moviesJSON = json["movies"] as? RawJSON,
            let movies = TraktLastActivityMovies(json: moviesJSON),
            let episodesJSON = json["episodes"] as? RawJSON,
            let episodes = TraktLastActivityEpisodes(json: episodesJSON),
            let showsJSON = json["shows"] as? RawJSON,
            let shows = TraktLastActivityShows(json: showsJSON),
            let seasonsJSON = json["seasons"] as? RawJSON,
            let seasons = TraktLastActivitySeasons(json: seasonsJSON),
            let commentsJSON = json["comments"] as? RawJSON,
            let comments = TraktLastActivityComments(json: commentsJSON),
            let listsJSON = json["lists"] as? RawJSON,
            let lists = TraktLastActivityLists(json: listsJSON) else { return nil }
        
        self.all        = all
        self.movies     = movies
        self.episodes   = episodes
        self.shows      = shows
        self.seasons    = seasons
        self.comments   = comments
        self.lists      = lists
    }
}

public struct TraktLastActivityMovies: TraktProtocol {
    public let watchedAt: Date
    public let collectedAt: Date
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    public let pausedAt: Date
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let watchedAt = Date.dateFromString(json["watched_at"]),
            let collectedAt = Date.dateFromString(json["collected_at"]),
            let ratedAt = Date.dateFromString(json["rated_at"]),
            let watchlistedAt = Date.dateFromString(json["watchlisted_at"]),
            let commentedAt = Date.dateFromString(json["commented_at"]),
            let pausedAt = Date.dateFromString(json["paused_at"]) else { return nil }
        
        self.watchedAt      = watchedAt
        self.collectedAt    = collectedAt
        self.ratedAt        = ratedAt
        self.watchlistedAt  = watchlistedAt
        self.commentedAt    = commentedAt
        self.pausedAt       = pausedAt
    }
}

public struct TraktLastActivityEpisodes: TraktProtocol {
    public let watchedAt: Date
    public let collectedAt: Date
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    public let pausedAt: Date
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let watchedAt = Date.dateFromString(json["watched_at"]),
            let collectedAt = Date.dateFromString(json["collected_at"]),
            let ratedAt = Date.dateFromString(json["rated_at"]),
            let watchlistedAt = Date.dateFromString(json["watchlisted_at"]),
            let commentedAt = Date.dateFromString(json["commented_at"]),
            let pausedAt = Date.dateFromString(json["paused_at"]) else { return nil }
        
        self.watchedAt = watchedAt
        self.collectedAt = collectedAt
        self.ratedAt = ratedAt
        self.watchlistedAt = watchlistedAt
        self.commentedAt = commentedAt
        self.pausedAt = pausedAt
    }
}

public struct TraktLastActivityShows: TraktProtocol {
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let ratedAt = Date.dateFromString(json["rated_at"]),
            let watchlistedAt = Date.dateFromString(json["watchlisted_at"]),
            let commentedAt = Date.dateFromString(json["commented_at"]) else { return nil }
        
        self.ratedAt = ratedAt
        self.watchlistedAt = watchlistedAt
        self.commentedAt = commentedAt
    }
}

public struct TraktLastActivitySeasons: TraktProtocol {
    public let ratedAt: Date
    public let watchlistedAt: Date
    public let commentedAt: Date
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let ratedAt = Date.dateFromString(json["rated_at"]),
            let watchlistedAt = Date.dateFromString(json["watchlisted_at"]),
            let commentedAt = Date.dateFromString(json["commented_at"]) else { return nil }
        
        self.ratedAt = ratedAt
        self.watchlistedAt = watchlistedAt
        self.commentedAt = commentedAt
    }
}

public struct TraktLastActivityComments: TraktProtocol {
    public let likedAt: Date
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let likedAt = Date.dateFromString(json["liked_at"]) else { return nil }
        
        self.likedAt = likedAt
    }
}

public struct TraktLastActivityLists: TraktProtocol {
    public let likedAt: Date
    public let updatedAt: Date
    public let commentedAt: Date
    
    // Initialization
    
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let likedAt = Date.dateFromString(json["liked_at"]),
            let updatedAt = Date.dateFromString(json["updated_at"]),
            let commentedAt = Date.dateFromString(json["commented_at"]) else { return nil }
        
        self.likedAt = likedAt
        self.updatedAt = updatedAt
        self.commentedAt = commentedAt
    }
}
