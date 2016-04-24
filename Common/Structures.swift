//
//  Structures.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/4/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public typealias RawJSON = [String: AnyObject] // Dictionary

public protocol TraktProtocol {
    init?(json: RawJSON?) // Min data must be present not to fail
}

func initEach<T: TraktProtocol>(dictionaries: [RawJSON]) -> [T] {
    var array = [T]()
    for dictionary in dictionaries {
        if let object = T(json: dictionary) {
            array.append(object)
        }
    }
    
    return array
}

// MARK: - TV & Movies

public struct ID: TraktProtocol {
    public let trakt: Int
    public let slug: String?
    public let tvdb: Int?
    public let imdb: String?
    public let tmdb: Int?
    public let tvRage: Int?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            traktID = json["trakt"] as? Int else { return nil }
        
        trakt = traktID
        slug = json["slug"] as? String
        tvdb = json["tvdb"] as? Int
        imdb = json["imdb"] as? String
        tmdb = json["tmdb"] as? Int
        tvRage = json["tvrage"] as? Int
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
        guard let json = json,
            watchers = json["watchers"] as? Int,
            plays = json["plays"] as? Int,
            collectors = json["collectors"] as? Int,
            comments = json["comments"] as? Int,
            lists = json["lists"] as? Int,
            votes = json["votes"] as? Int else { return nil }
        
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
    public let all: NSDate
    public let movies: TraktLastActivityMovies
    public let episodes: TraktLastActivityEpisodes
    public let shows: TraktLastActivityShows
    public let seasons: TraktLastActivitySeasons
    public let comments: TraktLastActivityComments
    public let lists: TraktLastActivityLists
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            allJSON = json["all"] ,
            all = NSDate.dateFromString(allJSON),
            moviesJSON = json["movies"] as? RawJSON,
            movies = TraktLastActivityMovies(json: moviesJSON),
            episodesJSON = json["episodes"] as? RawJSON,
            episodes = TraktLastActivityEpisodes(json: episodesJSON),
            showsJSON = json["shows"] as? RawJSON,
            shows = TraktLastActivityShows(json: showsJSON),
            seasonsJSON = json["seasons"] as? RawJSON,
            seasons = TraktLastActivitySeasons(json: seasonsJSON),
            commentsJSON = json["comments"] as? RawJSON,
            comments = TraktLastActivityComments(json: commentsJSON),
            listsJSON = json["lists"] as? RawJSON,
            lists = TraktLastActivityLists(json: listsJSON) else { return nil }
        
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
    public let watchedAt: NSDate
    public let collectedAt: NSDate
    public let ratedAt: NSDate
    public let watchlistedAt: NSDate
    public let commentedAt: NSDate
    public let pausedAt: NSDate
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            watchedAt = NSDate.dateFromString(json["watched_at"]),
            collectedAt = NSDate.dateFromString(json["collected_at"]),
            ratedAt = NSDate.dateFromString(json["rated_at"]),
            watchlistedAt = NSDate.dateFromString(json["watchlisted_at"]),
            commentedAt = NSDate.dateFromString(json["commented_at"]),
            pausedAt = NSDate.dateFromString(json["paused_at"]) else { return nil }
        
        self.watchedAt      = watchedAt
        self.collectedAt    = collectedAt
        self.ratedAt        = ratedAt
        self.watchlistedAt  = watchlistedAt
        self.commentedAt    = commentedAt
        self.pausedAt       = pausedAt
    }
}

public struct TraktLastActivityEpisodes: TraktProtocol {
    public let watchedAt: NSDate
    public let collectedAt: NSDate
    public let ratedAt: NSDate
    public let watchlistedAt: NSDate
    public let commentedAt: NSDate
    public let pausedAt: NSDate
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            watchedAt = NSDate.dateFromString(json["watched_at"]),
            collectedAt = NSDate.dateFromString(json["collected_at"]),
            ratedAt = NSDate.dateFromString(json["rated_at"]),
            watchlistedAt = NSDate.dateFromString(json["watchlisted_at"]),
            commentedAt = NSDate.dateFromString(json["commented_at"]),
            pausedAt = NSDate.dateFromString(json["paused_at"]) else { return nil }
        
        self.watchedAt = watchedAt
        self.collectedAt = collectedAt
        self.ratedAt = ratedAt
        self.watchlistedAt = watchlistedAt
        self.commentedAt = commentedAt
        self.pausedAt = pausedAt
    }
}

public struct TraktLastActivityShows: TraktProtocol {
    public let ratedAt: NSDate
    public let watchlistedAt: NSDate
    public let commentedAt: NSDate
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            ratedAt = NSDate.dateFromString(json["rated_at"]),
            watchlistedAt = NSDate.dateFromString(json["watchlisted_at"]),
            commentedAt = NSDate.dateFromString(json["commented_at"]) else { return nil }
        
        self.ratedAt = ratedAt
        self.watchlistedAt = watchlistedAt
        self.commentedAt = commentedAt
    }
}

public struct TraktLastActivitySeasons: TraktProtocol {
    public let ratedAt: NSDate
    public let watchlistedAt: NSDate
    public let commentedAt: NSDate
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            ratedAt = NSDate.dateFromString(json["rated_at"]),
            watchlistedAt = NSDate.dateFromString(json["watchlisted_at"]),
            commentedAt = NSDate.dateFromString(json["commented_at"]) else { return nil }
        
        self.ratedAt = ratedAt
        self.watchlistedAt = watchlistedAt
        self.commentedAt = commentedAt
    }
}

public struct TraktLastActivityComments: TraktProtocol {
    public let likedAt: NSDate
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            likedAt = NSDate.dateFromString(json["liked_at"]) else { return nil }
        
        self.likedAt = likedAt
    }
}

public struct TraktLastActivityLists: TraktProtocol {
    public let likedAt: NSDate
    public let updatedAt: NSDate
    public let commentedAt: NSDate
    
    // Initialization
    
    public init?(json: RawJSON?) {
        guard let json = json,
            likedAt = NSDate.dateFromString(json["liked_at"]),
            updatedAt = NSDate.dateFromString(json["updated_at"]),
            commentedAt = NSDate.dateFromString(json["commented_at"]) else { return nil }
        
        self.likedAt = likedAt
        self.updatedAt = updatedAt
        self.commentedAt = commentedAt
    }
}
