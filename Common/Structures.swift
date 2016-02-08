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

public struct TraktSearchResult: TraktProtocol {
    public let type: String // Can be movie, show, episode, person, list
    public let score: Double
    
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let episode: TraktEpisode?
    public let person: Person?
    public let list: TraktList?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
        type = json["type"] as? String,
        score = json["score"] as? Double else { return nil }
        
        self.type = type
        self.score = score
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
        self.episode = TraktEpisode(json: json["episode"] as? RawJSON)
        self.person = Person(json: json["person"] as? RawJSON)
        self.list = TraktList(json: json["list"] as? RawJSON)
    }
}

// MARK: - Images

public struct TraktImages: TraktProtocol {
    public let fanart: TraktImage?
    public let poster: TraktImage?
    public let logo: TraktImage?
    public let clearArt: TraktImage?
    public let banner: TraktImage?
    public let thumb: TraktImage?
    public let headshot: TraktImage?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json else { return nil }
        
        fanart      = TraktImage(json: json["fanart"] as? RawJSON)
        poster      = TraktImage(json: json["poster"] as? RawJSON)
        logo        = TraktImage(json: json["logo"] as? RawJSON)
        clearArt    = TraktImage(json: json["clearart"] as? RawJSON)
        banner      = TraktImage(json: json["banner"] as? RawJSON)
        thumb       = TraktImage(json: json["thumb"] as? RawJSON)
        headshot    = TraktImage(json: json["headshot"] as? RawJSON) // For actors
    }
}

public struct TraktImage: TraktProtocol {
    public let full: NSURL?
    public let medium: NSURL?
    public let thumb: NSURL?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json else { return nil }
        
        full = NSURL(string: json["full"] as? String ?? "") ?? nil
        medium = NSURL(string: json["medium"] as? String ?? "") ?? nil
        thumb = NSURL(string: json["thumb"] as? String ?? "") ?? nil
    }
}

// MARK: - Television

public struct TraktTrendingShow: TraktProtocol {
    // Extended: Min
    public let watchers: Int
    public let show: TraktShow
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
        watchers = json["watchers"] as? Int,
        show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.watchers = watchers
        self.show = show
    }
}

// Used for most played, watched, and collected shows
public struct TraktMostShow: TraktProtocol {
    // Extended: Min
    public let watcherCount: Int
    public let playCount: Int
    public let collectedCount: Int
    public let collectorCount: Int
    public let show: TraktShow
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            watcherCount = json["watcher_count"] as? Int,
            playCount = json["play_count"] as? Int,
            collectedCount = json["collected_count"] as? Int,
            collectorCount = json["collector_count"] as? Int,
            show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.watcherCount = watcherCount
        self.playCount = playCount
        self.collectedCount = collectedCount
        self.collectorCount = collectorCount
        self.show = show
    }
}

public struct TraktAnticipatedShow: TraktProtocol {
    // Extended: Min
    public let listCount: Int
    public let show: TraktShow
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            listCount = json["list_count"] as? Int,
            show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.listCount = listCount
        self.show = show
    }
}

public struct TraktShow: TraktProtocol {
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let overview: String?
    public let firstAired: NSDate?
    public let airs: RawJSON? // TODO: Make as type
    public let runtime: Int?
    public let certification: String?
    public let network: String?
    public let country: String?
    public let trailer: NSURL?
    public let homepage: NSURL?
    public let status: String?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: NSDate?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let airedEpisodes: Int?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json else { return nil }
        
        // Extended: Min
        title   = json["title"] as? String ?? ""
        year    = json["year"] as? Int
        guard let ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        self.ids = ids
        
        // Extended: Full
        overview        = json["overview"] as? String
        firstAired      = NSDate.dateFromString(json["first_aired"] as? String)
        airs            = json["airs"] as? RawJSON
        runtime         = json["runtime"] as? Int
        certification   = json["certification"] as? String
        network         = json["network"] as? String
        country         = json["country"] as? String
        trailer         = NSURL(string: json["trailer"] as? String ?? "") ?? nil
        homepage        = NSURL(string: json["homepage"] as? String ?? "") ?? nil
        status          = json["status"] as? String
        rating          = json["rating"] as? Double
        votes           = json["votes"] as? Int
        updatedAt       = NSDate.dateFromString(json["updated_at"] as? String)
        language        = json["language"] as? String
        availableTranslations = json["available_translations"] as? [String]
        genres          = json["genres"] as? [String]
        airedEpisodes   = json["aired_episodes"] as? Int
        
        // Extended: Images
        if let imageJSON = json["images"] as? RawJSON {
            images = TraktImages(json: imageJSON)
        }
        else {
            images = nil
        }
    }
}

public struct TraktSeason: TraktProtocol {
    // Extended: Min
    public let show: TraktShow
    public let number: Int
    public let ids: ID
    
    // Extended: Full
    
    // Initialize
    public init?(json: RawJSON?) {
        fatalError("init?(json:?) has not been implemented")
    }
    
    public init?(json: RawJSON?, show: TraktShow) {
        guard let json = json,
            number = json["number"] as? Int,
            ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        self.show   = show
        self.number = number
        self.ids    = ids
    }
}

public struct TraktEpisode: TraktProtocol {
    // Extended: Min
    public let season: TraktSeason?
    public let number: Int
    public let title: String
    public let ids: ID
    
    // Extended: Full
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            number = json["number"] as? Int,
            title = json["title"] as? String,
            ids = ID(json: json["ids"] as? RawJSON) else { return nil }

        self.season = nil
        self.number = number
        self.title  = title
        self.ids    = ids
    }
    
    public init?(json: RawJSON?, season: TraktSeason) {
        guard let json = json,
            number = json["number"] as? Int,
            title = json["title"] as? String,
            ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        self.season = season
        self.number = number
        self.title  = title
        self.ids    = ids
    }
}

public struct TraktShowTranslation: TraktProtocol {
    public let title: String
    public let overview: String
    public let language: String
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
        title = json["title"] as? String,
        overview = json["overview"] as? String,
        language = json["language"] as? String else { return nil }
        
        self.title       = title
        self.overview    = overview
        self.language    = language
    }
}

// MARK: Watched progress

public struct TraktWatchedShow: TraktProtocol {
    // Extended: Min
    public let plays: Int // Total number of plays
    public let lastWatchedAt: NSDate
    public let show: TraktShow
    public let seasons: [TraktWatchedSeason]
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            plays = json["plays"] as? Int,
            lastWatchedAt = NSDate.dateFromString(json["last_watched_at"] as? String),
            show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.plays = plays
        self.lastWatchedAt = lastWatchedAt
        self.show = show
        
        var tempSeasons: [TraktWatchedSeason] = []
        let jsonSeasons = json["seasons"] as? [RawJSON] ?? []
        for jsonSeason in jsonSeasons {
            guard let season = TraktWatchedSeason(json: jsonSeason) else { continue }
            tempSeasons.append(season)
        }
        seasons = tempSeasons
    }
}

public struct TraktWatchedSeason: TraktProtocol {
    // Extended: Min
    public let number: Int // Season number
    public let episodes: [TraktWatchedEpisodes]
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            number = json["number"] as? Int else { return nil }
        
        self.number = number
        
        var tempEpisodes: [TraktWatchedEpisodes] = []
        let jsonEpisodes = json["episodes"] as? [RawJSON] ?? []
        for jsonEpisode in jsonEpisodes {
            tempEpisodes.append(TraktWatchedEpisodes(json: jsonEpisode))
        }
        episodes = tempEpisodes
    }
}

public struct TraktWatchedEpisodes: TraktProtocol {
    // Extended: Min
    public let number: Int // Episode number
    public let plays: Int // Number of plays
    public let lastWatchedAt: NSDate
    
    // Initialize
    public init(json: RawJSON) {
        number = json["number"] as? Int ?? 0
        plays = json["plays"] as? Int ?? 0
        lastWatchedAt = NSDate.dateFromString(json["last_watched_at"] as? String) ?? NSDate()
    }
    
    public init?(json: RawJSON?) {
        guard let json = json,
            number = json["number"] as? Int,
            plays = json["plays"] as? Int,
            lastWatchedAt = NSDate.dateFromString(json["last_watched_at"] as? String) else { return nil }
        
        self.number = number
        self.plays = plays
        self.lastWatchedAt = lastWatchedAt
    }
}

// MARK: - Movies

public struct TraktTrendingMovie: TraktProtocol {
    // Extended: Min
    public let watchers: Int
    public let movie: TraktMovie
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            watchers = json["watchers"] as? Int,
            movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
        
        self.watchers = watchers
        self.movie = movie
    }
}

public struct TraktMovie: TraktProtocol {
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let tagline: String?
    public let overview: String?
    public let released: NSDate?
    public let runtime: Int?
    public let trailer: NSURL?
    public let homepage: NSURL?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: NSDate?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let certification: String?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
        title = json["title"] as? String,
        ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        // Extended: Min
        self.title = title
        self.year = json["year"] as? Int
        self.ids = ids
        
        // Extended: Full
        self.tagline             = json["overview"] as? String
        self.overview            = json["overview"] as? String
        self.released            = NSDate.dateFromString(json["released"] as? String)
        self.runtime             = json["runtime"] as? Int
        self.trailer             = NSURL(string: json["trailer"] as? String ?? "") ?? nil
        self.homepage            = NSURL(string: json["homepage"] as? String ?? "") ?? nil
        self.rating              = json["rating"] as? Double
        self.votes               = json["votes"] as? Int
        self.updatedAt           = NSDate.dateFromString(json["updated_at"] as? String)
        self.language            = json["language"] as? String
        self.availableTranslations = json["available_translations"] as? [String]
        self.genres              = json["genres"] as? [String]
        self.certification       = json["certification"] as? String
        
        // Extended: Images
        if let imageJSON = json["images"] as? RawJSON {
            images = TraktImages(json: imageJSON)
        }
        else {
            images = nil
        }
    }
}

public struct TraktMovieTranslation: TraktProtocol {
    public let title: String
    public let overview: String
    public let tagline: String
    public let language: String
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            title = json["title"] as? String,
            overview = json["overview"] as? String,
            tagline = json["tagline"] as? String,
            language = json["language"] as? String else { return nil }
        
        self.title = title
        self.overview = overview
        self.tagline = tagline
        self.language = language
    }
}

// MARK: Watched progress

public struct TraktWatchedMovie: TraktProtocol {
    // Extended: Min
    public let plays: Int // Total number of plays
    public let lastWatchedAt: NSDate
    public let movie: TraktMovie
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            plays = json["plays"] as? Int,
            lastWatchedAt = NSDate.dateFromString(json["last_watched_at"] as? String),
            movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
        
        self.plays = plays
        self.lastWatchedAt = lastWatchedAt
        self.movie = movie
    }
}

// MARK: - Comments

public struct Comment: TraktProtocol {
    public let id: NSNumber
    public let parentID: NSNumber
    public let createdAt: NSDate // TODO: Make NSDate
    public let comment: String
    public let spoiler: Bool
    public let review: Bool
    public let replies: NSNumber
    public let userRating: NSNumber
    public let user: User
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            id = json["id"] as? NSNumber,
            parentID = json["parent_id"] as? NSNumber,
            createdAt = NSDate.dateFromString(json["created_at"] as? String),
            comment = json["comment"] as? String,
            spoiler = json["spoiler"] as? Bool,
            review = json["review"] as? Bool,
            replies = json["replies"] as? NSNumber,
            userRating = json["user_rating"] as? NSNumber,
            user = User(json: json["user"] as? RawJSON) else { return nil }
        
        self.id = id
        self.parentID = parentID
        self.createdAt = createdAt
        self.comment = comment
        self.spoiler = spoiler
        self.review = review
        self.replies = replies
        self.userRating = userRating
        self.user = user
    }
}

// Trakt user
public struct User: TraktProtocol {
    public let username: String
    public let isPrivate: Bool
    public let name: String
    public let isVIP: Bool
    public let isVIPEP: Bool
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            isPrivate = json["private"] as? Bool,
            isVIP = json["vip"] as? Bool,
            isVIPEP = json["vip_ep"] as? Bool else { return nil }
        
        self.username = json["username"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        self.isPrivate = isPrivate
        self.name = json["name"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        self.isVIP = isVIP
        self.isVIPEP = isVIPEP
    }
}

// MARK: - People

// Actor/Actress/Crew member
public struct Person: TraktProtocol {
    // Extended: Min
    public let name: String
    public let ids: ID
    
    // Extended: Full
    public let biography: String?
    public let birthday: NSDate?
    public let death: NSDate?
    public let birthplace: String?
    public let homepage: NSURL?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            name = json["name"] as? String,
            ids = ID(json: json["ids"] as? [String: AnyObject]) else { return nil }

        // Extended: Min
        self.name = name
        self.ids = ids
        
        // Extended: Full
        biography   = json["biography"] as? String
        birthday    = NSDate.dateFromString(json["birthday"] as? String)
        death       = NSDate.dateFromString(json["death"] as? String)
        birthplace  = json["birthplace"] as? String
        
        if let homepageString = json["homepage"] as? String {
            homepage = NSURL(string: homepageString)
        }
        else {
            homepage = nil
        }
        
        // Extended: Images
        if let imageJSON = json["images"] as? RawJSON {
            images = TraktImages(json: imageJSON)
        }
        else {
            images = nil
        }
    }
}

public struct CrewMember: TraktProtocol {
    public let job: String
    public let person: Person
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            job = json["job"] as? String,
            person = Person(json: json["person"] as? RawJSON) else { return nil }
        
        self.job = job
        self.person = person
    }
}

public struct CastMember: TraktProtocol {
    public let character: String
    public let person: Person
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            character = json["character"] as? String,
            person = Person(json: json["person"] as? RawJSON) else { return nil }
        
        self.character = character
        self.person = person
    }
}

// MARK: - List

public struct TraktList: TraktProtocol {
    public let name: String
    public let description: String
    public let privacy: String // TODO: Maybe make a type?
    public let displayNumbers: Bool
    public let allowComments: Bool
    public let id: ID
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            name = json["name"] as? String,
            description = json["description"] as? String,
            privacy = json["privacy"] as? String,
            displayNumbers = json["display_numbers"] as? Bool,
            allowComments = json["allow_comments"] as? Bool,
            id = ID(json: json["ids"] as? RawJSON)
            else { return nil }
        
        self.name            = name
        self.description     = description
        self.privacy         = privacy
        self.displayNumbers  = displayNumbers
        self.allowComments   = allowComments
        self.id              = id
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
            allJSON = json["all"] as? String,
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
            watchedAt = NSDate.dateFromString(json["watched_at"] as? String),
            collectedAt = NSDate.dateFromString(json["collected_at"] as? String),
            ratedAt = NSDate.dateFromString(json["rated_at"] as? String),
            watchlistedAt = NSDate.dateFromString(json["watchlisted_at"] as? String),
            commentedAt = NSDate.dateFromString(json["commented_at"] as? String),
            pausedAt = NSDate.dateFromString(json["paused_at"] as? String) else { return nil }
        
        self.watchedAt = watchedAt
        self.collectedAt = collectedAt
        self.ratedAt = ratedAt
        self.watchlistedAt = watchlistedAt
        self.commentedAt = commentedAt
        self.pausedAt = pausedAt
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
            watchedAt = NSDate.dateFromString(json["watched_at"] as? String),
            collectedAt = NSDate.dateFromString(json["collected_at"] as? String),
            ratedAt = NSDate.dateFromString(json["rated_at"] as? String),
            watchlistedAt = NSDate.dateFromString(json["watchlisted_at"] as? String),
            commentedAt = NSDate.dateFromString(json["commented_at"] as? String),
            pausedAt = NSDate.dateFromString(json["paused_at"] as? String) else { return nil }
        
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
            ratedAt = NSDate.dateFromString(json["rated_at"] as? String),
            watchlistedAt = NSDate.dateFromString(json["watchlisted_at"] as? String),
            commentedAt = NSDate.dateFromString(json["commented_at"] as? String) else { return nil }
        
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
        ratedAt = NSDate.dateFromString(json["rated_at"] as? String),
        watchlistedAt = NSDate.dateFromString(json["watchlisted_at"] as? String),
        commentedAt = NSDate.dateFromString(json["commented_at"] as? String) else { return nil }
        
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
            likedAt = NSDate.dateFromString(json["liked_at"] as? String) else { return nil }
        
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
            likedAt = NSDate.dateFromString(json["liked_at"] as? String),
            updatedAt = NSDate.dateFromString(json["updated_at"] as? String),
            commentedAt = NSDate.dateFromString(json["commented_at"] as? String) else { return nil }
        
        self.likedAt = likedAt
        self.updatedAt = updatedAt
        self.commentedAt = commentedAt
    }
}
