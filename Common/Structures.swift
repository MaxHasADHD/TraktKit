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
    init(json: RawJSON)
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
    public init(json: RawJSON) {
        trakt   = json["trakt"] as? Int ?? 0
        slug    = json["slug"] as? String
        tvdb    = json["tvdb"] as? Int
        imdb    = json["imdb"] as? String
        tmdb    = json["tmdb"] as? Int
        tvRage  = json["tvrage"] as? Int
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
    public init(json: RawJSON) {
        type = json["type"] as? String ?? "" // Should this fail then?
        score = json["score"] as? Double ?? 0
        
        if let movieJSON = json["movie"] as? RawJSON {
            movie = TraktMovie(json: movieJSON)
        }
        else {
            movie = nil
        }
        
        if let showJSON = json["show"] as? RawJSON {
            show = TraktShow(json: showJSON)
        }
        else {
            show = nil
        }
        
        if let episodeJSON = json["episode"] as? RawJSON {
            episode = TraktEpisode(json: episodeJSON)
        }
        else {
            episode = nil
        }
        
        if let personJSON = json["person"] as? RawJSON {
            person = Person(json: personJSON)
        }
        else {
            person = nil
        }
        
        if let listJSON = json["list"] as? RawJSON {
            list = TraktList(json: listJSON)
        }
        else {
            list = nil
        }
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
    public init(json: RawJSON) {
        fanart = TraktImage(optionalJSON: json["fanart"] as? RawJSON)
        poster = TraktImage(optionalJSON: json["poster"] as? RawJSON)
        logo = TraktImage(optionalJSON: json["logo"] as? RawJSON)
        clearArt = TraktImage(optionalJSON: json["clearart"] as? RawJSON)
        banner = TraktImage(optionalJSON: json["banner"] as? RawJSON)
        thumb = TraktImage(optionalJSON: json["thumb"] as? RawJSON)
        
        headshot = TraktImage(optionalJSON: json["headshot"] as? RawJSON) // For actors
    }
}

public struct TraktImage: TraktProtocol {
    public let full: NSURL?
    public let medium: NSURL?
    public let thumb: NSURL?
    
    // Initialize
    public init(json: RawJSON) {
        full = NSURL(string: json["full"] as? String ?? "") ?? nil
        medium = NSURL(string: json["medium"] as? String ?? "") ?? nil
        thumb = NSURL(string: json["thumb"] as? String ?? "") ?? nil
    }
    
    public init?(optionalJSON: RawJSON?) { // Makes easier to code instead of a bunch of if-lets for TraktImages
        if let json = optionalJSON {
            full = NSURL(string: json["full"] as? String ?? "") ?? nil
            medium = NSURL(string: json["medium"] as? String ?? "") ?? nil
            thumb = NSURL(string: json["thumb"] as? String ?? "") ?? nil
        }
        else {
            full = nil
            medium = nil
            thumb = nil
            return nil
        }
    }
}

// MARK: - Television

public struct TraktTrendingShow: TraktProtocol {
    // Extended: Min
    public let watchers: Int
    public let show: TraktShow
    
    // Initialize
    public init(json: RawJSON) {
        watchers    = json["watchers"] as? Int ?? 0
        show        = TraktShow(json: json["show"] as! RawJSON)
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
    public init(json: RawJSON) {
        watcherCount    = json["watcher_count"] as? Int ?? 0
        playCount       = json["play_count"] as? Int ?? 0
        collectedCount  = json["collected_count"] as? Int ?? 0
        collectorCount  = json["collector_count"] as? Int ?? 0
        show            = TraktShow(json: json["show"] as! RawJSON)
    }
}

public struct TraktAnticipatedShow: TraktProtocol {
    // Extended: Min
    public let listCount: Int
    public let show: TraktShow
    
    // Initialize
    public init(json: RawJSON) {
        listCount   = json["list_count"] as? Int ?? 0
        show        = TraktShow(json: json["show"] as! RawJSON)
    }
}

public struct TraktShow: TraktProtocol {
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let overview: String?
    public let firstAired: String? // TODO: Make NSDate
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
    public let updatedAt: String? // TODO: Make NSDate
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let airedEpisodes: Int?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init(json: RawJSON) {
        // Extended: Min
        title   = json["title"] as? String ?? ""
        year    = json["year"] as? Int
        ids     = ID(json: json["ids"] as! RawJSON)
        
        // Extended: Full
        overview        = json["overview"] as? String
        firstAired      = json["first_aired"] as? String
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
        updatedAt       = json["updated_at"] as? String
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
    public init(json: RawJSON) {
        fatalError("init(json:) has not been implemented")
    }
    
    public init(json: RawJSON, show: TraktShow) {
        self.show   = show
        number      = json["number"] as? Int ?? 0
        ids         = ID(json: json["ids"] as! RawJSON)
    }
}

public struct TraktEpisode: TraktProtocol {
    // Extended: Min
    public let season: TraktSeason
    public let number: Int
    public let title: String
    public let ids: ID
    
    // Extended: Full
    
    // Initialize
    public init(json: RawJSON) {
        fatalError("init(json:) has not been implemented")
    }
    
    public init(json: RawJSON, season: TraktSeason) {
        self.season = season
        number      = json["number"] as? Int ?? 0
        title       = json["title"] as? String ?? "TBA"
        ids         = ID(json: json["ids"] as! RawJSON)
    }
}

public struct TraktShowTranslation: TraktProtocol {
    public let title: String
    public let overview: String
    public let language: String
    
    // Initialize
    public init(json: RawJSON) {
        title       = json["title"] as? String ?? ""
        overview    = json["overview"] as? String ?? ""
        language    = json["language"] as? String ?? ""
    }
}

// MARK: - Movies

public struct TraktTrendingMovie: TraktProtocol {
    // Extended: Min
    public let watchers: Int
    public let movie: TraktMovie
    
    // Initialize
    public init(json: RawJSON) {
        watchers = json["watchers"] as? Int ?? 0
        movie = TraktMovie(json: json["movie"] as! RawJSON)
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
    public let released: String? // TODO: Make NSDate
    public let runtime: Int?
    public let trailer: NSURL?
    public let homepage: NSURL?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: String? // TODO: Make NSDate
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let certification: String?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init(json: RawJSON) {
        // Extended: Min
        title   = json["title"] as? String ?? ""
        year    = json["year"] as? Int
        ids     = ID(json: json["ids"] as! RawJSON)
        
        // Extended: Full
        tagline             = json["overview"] as? String
        overview            = json["overview"] as? String
        released            = json["released"] as? String
        runtime             = json["runtime"] as? Int
        trailer             = NSURL(string: json["trailer"] as? String ?? "") ?? nil
        homepage            = NSURL(string: json["homepage"] as? String ?? "") ?? nil
        rating              = json["rating"] as? Double
        votes               = json["votes"] as? Int
        updatedAt           = json["updated_at"] as? String
        language            = json["language"] as? String
        availableTranslations = json["available_translations"] as? [String]
        genres              = json["genres"] as? [String]
        certification       = json["certification"] as? String
        
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
    public init(json: RawJSON) {
        title       = json["title"] as? String ?? ""
        overview    = json["overview"] as? String ?? ""
        tagline     = json["tagline"] as? String ?? ""
        language    = json["language"] as? String ?? ""
    }
}

// MARK: - Comments

public struct Comment: TraktProtocol {
    public let id: NSNumber
    public let parentID: NSNumber
    public let createdAt: String // TODO: Make NSDate
    public let comment: String
    public let spoiler: Bool
    public let review: Bool
    public let replies: NSNumber
    public let userRating: NSNumber
    public let user: User
    
    // Initialize
    public init(json: RawJSON) {
        id = json["id"] as? NSNumber ?? 0
        parentID = json["parent_id"] as? NSNumber ?? 0
        createdAt = json["created_at"] as? String ?? ""
        comment = json["comment"] as? String ?? NSLocalizedString("COMMENTS_UNAVAILABLE", comment: "Comment Unavailable")
        spoiler = json["spoiler"] as? Bool ?? false
        review = json["review"] as? Bool ?? false
        replies = json["replies"] as? NSNumber ?? 0
        userRating = json["user_rating"] as? NSNumber ?? 0
        user = User(json: json["user"] as! RawJSON)
    }
}

public extension SequenceType where Generator.Element == Comment {
    public func hideSpoilers() -> [Comment] {
        return self.filter { $0.spoiler == false }
    }
}

// Trakt user
public struct User: TraktProtocol {
    public let username: String
    public let isPrivate: Bool
    public let name: String
    public let isVIP: Bool
    public let isVIPEP: Bool
    
    public init(json: [String: AnyObject]) {
        username = json["username"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        isPrivate = json["private"] as? Bool ?? false
        name = json["name"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        isVIP = json["vip"] as? Bool ?? false
        isVIPEP = json["vip_ep"] as? Bool ?? false
    }
}

// MARK: - People

// Actor/Actress/Crew member
public struct Person: TraktProtocol {
    // Extended: Min
    public let name: String
    public let idTrakt: NSNumber
    public let idSlug: String
    public let idTMDB: NSNumber
    public let idIMDB: String
    public let idTVRage: NSNumber
    
    // Extended: Full
    public let biography: String?
    public let birthday: String? // TODO: Make NSDate
    public let death: String? // TODO: Make NSDate
    public let birthplace: String?
    public let homepage: NSURL?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init(json: RawJSON) {
        // Extended: Min
        name = json["name"] as? String ?? ""
        
        if let ids = json["ids"] as? [String: AnyObject] {
            idTrakt = ids["trakt"] as? NSNumber ?? 0
            idSlug = ids["slug"] as? String ?? ""
            idTMDB = ids["tmdb"] as? NSNumber ?? 0
            idIMDB = ids["imdb"] as? String ?? ""
            idTVRage = ids["tvrage"] as? NSNumber ?? 0
        }
        else {
            idTrakt = 0
            idSlug = ""
            idTMDB = 0
            idIMDB = ""
            idTVRage = 0
        }
        
        // Extended: Full
        biography = json["biography"] as? String
        birthday = json["birthday"] as? String
        death = json["death"] as? String
        birthplace = json["birthplace"] as? String
        
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
    
    public init(json: RawJSON) {
        job = json["job"] as? String ?? ""
        person = Person(json: json["person"] as! RawJSON)
    }
}

public struct CastMember: TraktProtocol {
    public let character: String
    public let person: Person
    
    public init(json: RawJSON) {
        character = json["character"] as? String ?? ""
        person = Person(json: json["person"] as! RawJSON)
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
    public init(json: RawJSON) {
        name            = json["name"] as? String ?? ""
        description     = json["description"] as? String ?? ""
        privacy         = json["privacy"] as? String ?? ""
        displayNumbers  = json["display_numbers"] as? Bool ?? false
        allowComments   = json["allow_comments"] as? Bool ?? false
        id              = ID(json: json["ids"] as! RawJSON)
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
    public init(json: RawJSON) {
        watchers            = json["watchers"] as? Int ?? 0
        plays               = json["plays"] as? Int ?? 0
        collectors          = json["collectors"] as? Int ?? 0
        collectedEpisodes   = json["collected_episodes"] as? Int ?? 0 // Not included for movie stats
        comments            = json["comments"] as? Int ?? 0
        lists               = json["lists"] as? Int ?? 0
        votes               = json["votes"] as? Int ?? 0
    }
}