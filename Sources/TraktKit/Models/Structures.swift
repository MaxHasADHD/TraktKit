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

public struct ID: TraktObject {

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

public struct SeasonId: TraktObject {

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

public struct EpisodeId: TraktObject {
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

public struct ListId: TraktObject {
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

public struct TraktStats: TraktObject {
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

public struct TraktMovieStats: TraktObject {
    public let watchers: Int
    public let plays: Int
    public let collectors: Int
    public let comments: Int
    public let lists: Int
    public let votes: Int
    public let favorited: Int
}

// MARK: - Last Activities

public struct TraktLastActivities: TraktObject {
    public let all: Date
    public let movies: Movies
    public let episodes: Episodes
    public let shows: Shows
    public let seasons: Seasons
    public let comments: Comments
    public let lists: Lists
    public let watchlist: LastUpdated
    public let favorites: LastUpdated
    public let account: Account
    public let savedFilters: LastUpdated
    public let notes: LastUpdated

    enum CodingKeys: String, CodingKey {
        case all
        case movies
        case episodes
        case shows
        case seasons
        case comments
        case lists
        case watchlist
        case favorites
        case account
        case savedFilters = "saved_filters"
        case notes
    }

    public struct Movies: TraktObject {
        public let watchedAt: Date
        public let collectedAt: Date
        public let ratedAt: Date
        public let watchlistedAt: Date
        public let favoritesAt: Date
        public let commentedAt: Date
        public let pausedAt: Date
        public let hiddenAt: Date

        enum CodingKeys: String, CodingKey {
            case watchedAt = "watched_at"
            case collectedAt = "collected_at"
            case ratedAt = "rated_at"
            case watchlistedAt = "watchlisted_at"
            case favoritesAt = "favorited_at"
            case commentedAt = "commented_at"
            case pausedAt = "paused_at"
            case hiddenAt = "hidden_at"
        }
    }

    public struct Episodes: TraktObject {
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

    public struct Shows: TraktObject {
        public let ratedAt: Date
        public let watchlistedAt: Date
        public let favoritesAt: Date
        public let commentedAt: Date
        public let hiddenAt: Date
        public let droppedAt: Date

        enum CodingKeys: String, CodingKey {
            case ratedAt = "rated_at"
            case watchlistedAt = "watchlisted_at"
            case favoritesAt = "favorited_at"
            case commentedAt = "commented_at"
            case hiddenAt = "hidden_at"
            case droppedAt = "dropped_at"
        }
    }

    public struct Seasons: TraktObject {
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

    public struct Comments: TraktObject {
        public let likedAt: Date
        public let blockedAt: Date

        enum CodingKeys: String, CodingKey {
            case likedAt = "liked_at"
            case blockedAt = "blocked_at"
        }
    }

    public struct Lists: TraktObject {
        public let likedAt: Date
        public let updatedAt: Date
        public let commentedAt: Date

        enum CodingKeys: String, CodingKey {
            case likedAt = "liked_at"
            case updatedAt = "updated_at"
            case commentedAt = "commented_at"
        }
    }

    public struct Account: TraktObject {
        /// When the OAuth user updates any of their Trakt settings on the website
        public let settingsChanged: Date
        /// When another Trakt user follows or unfollows the OAuth user.
        public let followedChanged: Date
        /// When the OAuth user follows or unfollows another Trakt user.
        public let followingChanged: Date
        /// When the OAuth user follows a private account, which requires their approval.
        public let pendingFollowingChanged: Date
        /// When the OAuth user has a private account and someone requests to follow them.
        public let requestedFollowingChanged: Date

        enum CodingKeys: String, CodingKey {
            case settingsChanged = "settings_at"
            case followedChanged = "followed_at"
            case followingChanged = "following_at"
            case pendingFollowingChanged = "pending_at"
            case requestedFollowingChanged = "requested_at"
        }
    }

    /// Used for watchlist, favorites, saved filters, and notes.
    public struct LastUpdated: TraktObject {
        public let updatedAt: Date

        enum CodingKeys: String, CodingKey {
            case updatedAt = "updated_at"
        }
    }
}
