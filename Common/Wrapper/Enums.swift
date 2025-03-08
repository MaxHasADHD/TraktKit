//
//  Enums.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/22/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public enum Method: String, Sendable {
    /// Select one or more items. Success returns 200 status code.
    case GET
    /// Create a new item. Success returns 201 status code.
    case POST
    /// Update an item. Success returns 200 status code.
    case PUT
    /// Delete an item. Success returns 200 or 204 status code.
    case DELETE

    public var expectedResult: Int {
        switch self {
        case .GET:
            200
        case .POST:
            201
        case .PUT:
            200
        case .DELETE:
            204
        }
    }
}

public struct StatusCodes: Sendable {
    /// Success
    public static let Success = 200
    /// Success - new resource created (POST)
    public static let SuccessNewResourceCreated = 201
    /// Success - no content to return (DELETE)
    public static let SuccessNoContentToReturn = 204
    /// Bad Request - request couldn't be parsed
    public static let BadRequest = 400
    /// Unauthorized - OAuth must be provided
    public static let Unauthorized = 401
    /// Forbidden - invalid API key or unapproved app
    public static let Forbidden = 403
    /// Not Found - method exists, but no record found
    public static let NotFound = 404
    /// Method Not Found - method doesn't exist
    public static let MethodNotFound = 405
    /// Conflict - resource already created
    public static let Conflict = 409
    /// Precondition Failed - use application/json content type
    public static let PreconditionFailed = 412
    /// Account Limit Exceeded - list count, item count, etc
    public static let AccountLimitExceeded = 420
    /// Unprocessable Entity - validation errors
    public static let UnprocessableEntity = 422
    /// Trakt account locked. Have user contact Trakt https://github.com/trakt/api-help/issues/228
    public static let acountLocked = 423
    /// VIP Only - user must upgrade to VIP
    public static let vipOnly = 426
    /// Rate Limit Exceeded
    public static let RateLimitExceeded = 429
    /// Server Error
    public static let ServerError = 500
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError = 520
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError2 = 521
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError3 = 522
}

/// What to search for
public enum SearchType: String, Sendable {
    case movie
    case show
    case episode
    case person
    case list

    public struct Field: Sendable {
        public let title: String
    }
    public struct Fields {
        public struct Movie {
            public static let title = Field(title: "title")
            public static let tagline = Field(title: "tagline")
            public static let overview = Field(title: "overview")
            public static let people = Field(title: "people")
            public static let translations = Field(title: "translations")
            public static let aliases = Field(title: "aliases")
        }

        public struct Show {
            public static let title = Field(title: "title")
            public static let overview = Field(title: "overview")
            public static let people = Field(title: "people")
            public static let translations = Field(title: "translations")
            public static let aliases = Field(title: "aliases")
        }

        public struct Episode {
            public static let title = Field(title: "title")
            public static let overview = Field(title: "overview")
        }

        public struct Person {
            public static let name = Field(title: "name")
            public static let biography = Field(title: "biography")
        }

        public struct List {
            public static let name = Field(title: "name")
            public static let description = Field(title: "description")
        }
    }
}

/// Type of ID used for look up
public enum LookupType: Sendable {
    case Trakt(id: NSNumber)
    case IMDB(id: String)
    case TMDB(id: NSNumber)
    case TVDB(id: NSNumber)
    case TVRage(id: NSNumber)

    var name: String {
        switch self {
            case .Trakt:
                return "trakt"
            case .IMDB:
                return "imdb"
            case .TMDB:
                return "tmdb"
            case .TVDB:
                return "tvdb"
            case .TVRage:
                return "tvrage"
        }
    }

    var id: String {
        switch self {
        case .Trakt(let id):
            return "\(id)"
        case .IMDB(let id):
            return id
        case .TMDB(let id):
            return "\(id)"
        case .TVDB(let id):
            return "\(id)"
        case .TVRage(let id):
            return "\(id)"
        }
    }
}

public enum MediaType: String, CustomStringConvertible, Sendable {
    case movies, shows

    public var description: String {
        return self.rawValue
    }
}

public enum WatchedType: String, CustomStringConvertible, Sendable {
    case Movies = "movies"
    case Shows = "shows"
    case Seasons = "seasons"
    case Episodes = "episodes"

    public var description: String {
        return self.rawValue
    }
}

public enum Type2: String, CustomStringConvertible, Sendable {
    case All = "all"
    case Movies = "movies"
    case Shows = "shows"
    case Seasons = "seasons"
    case Episodes = "episodes"
    case Lists = "lists"

    public var description: String {
        return self.rawValue
    }
}

public enum ListType: String, CustomStringConvertible, Sendable {
    case all
    case personal
    case official
    case watchlists

    public var description: String {
        return self.rawValue
    }
}

public enum ListSortType: String, CustomStringConvertible, Sendable {
    case popular
    case likes
    case comments
    case items
    case added
    case updated

    public var description: String {
        return self.rawValue
    }
}

/// Type of comments
public enum CommentType: String, Sendable {
    case all = "all"
    case reviews = "reviews"
    case shouts = "shouts"
}

/// Extended information
public enum ExtendedType: String, CustomStringConvertible, Sendable {
    /// Least amount of info
    case Min = "min"
    /// All information, excluding images
    case Full = "full"
    /// Collection only. Additional video and audio info.
    case Metadata = "metadata"
    /// Get all seasons and episodes
    case Episodes = "episodes"
    /// Get watched shows without seasons. https://trakt.docs.apiary.io/#reference/users/watched/get-watched
    case noSeasons = "noseasons"
    /// For the show and season `/people` methods.
    case guestStars = "guest_stars"

    public var description: String {
        return self.rawValue
    }
}

extension Sequence where Iterator.Element: CustomStringConvertible {
    func queryString() -> String {
        return self.map { $0.description }.joined(separator: ",") // Search with multiple types
    }
}

/// Possible values for items in Lists
public enum ListItemType: String, Sendable {
    case movies = "movie"
    case shows = "show"
    case seasons = "season"
    case episodes = "episode"
    case people = "person"
}

public enum Period: String, Sendable, CustomStringConvertible {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    case all = "all"

    public var description: String {
        rawValue
    }
}

public struct HiddenItemSection: Sendable {
    /// Can hide movie, show objects
    public static let calendar = "calendar"
    /// Can hide show, season objects
    public static let progressWatched = "progress_watched"
    /// Can hide show, season objects
    public static let progressWatchedReset = "progress_watched_reset"
    /// Can hide show, season objects
    public static let progressCollected = "progress_collected"
    /// Can hide movie, show objects
    public static let recommendations = "recommendations"
    // Can hide users
    public static let comments = "comments"
    // Can hide shows
    public static let dropped = "dropped"
}

public enum HiddenItemsType: String, Sendable {
    case Movie = "movie"
    case Show = "show"
    case Season = "Season"
}

public enum LikeType: String, Sendable {
    case Comments = "comments"
    case Lists = "lists"
}
