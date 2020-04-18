//
//  Enums.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/22/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public enum Method: String {
    /// Select one or more items. Success returns 200 status code.
    case GET
    /// Create a new item. Success returns 201 status code.
    case POST
    /// Update an item. Success returns 200 status code.
    case PUT
    /// Delete an item. Success returns 200 or 204 status code.
    case DELETE
}

public struct StatusCodes {
    /// Success
    public static let Success = 200
    /// Success - new resource created (POST)
    public static let SuccessNewResourceCreated = 201
    /// Success - no content to return (DELETE)
    public static let SuccessNoContentToReturn = 204
    /// Bad Request - request couldn't be parsed
    public static let BadRequestion = 400
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
    /// Unprocessable Entity - validation errors
    public static let UnprocessableEntity = 422
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

    static func message(for status: Int) -> String? {
        switch status {
        case Unauthorized:
            return "App not authorized. Please sign in again."
        case Forbidden:
            return "Invalid API Key"
        case NotFound:
            return "API not found"
        case RateLimitExceeded:
            return "Rate Limit Exceeded. Please try again in a minute."
        case ServerError..<CloudflareError:
            return "Trakt.tv is down. Please try again later."
        case CloudflareError..<600:
            return "CloudFlare error. Please try again later."
        default:
            return nil
        }
    }
}

/// What to search for
public enum SearchType: String {
    case movie
    case show
    case episode
    case person
    case list

    public struct Field {
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
public enum LookupType {
    case Trakt(id: NSNumber)
    case IMDB(id: String)
    case TMDB(id: NSNumber)
    case TVDB(id: NSNumber)
    case TVRage(id: NSNumber)

    func name() -> String {
        switch self {
        case .Trakt(_):
            return "trakt"
        case .IMDB(_):
            return "imdb"
        case .TMDB(_):
            return "tmdb"
        case .TVDB(_):
            return "tvdb"
        case .TVRage(_):
            return "tvrage"
        }
    }

    func id() -> String {
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

public enum Type: String, CustomStringConvertible {
    case Movies = "movies"
    case Shows = "shows"

    public var description: String {
        return self.rawValue
    }
}

public enum WatchedType: String, CustomStringConvertible {
    case Movies = "movies"
    case Shows = "shows"
    case Seasons = "seasons"
    case Episodes = "episodes"

    public var description: String {
        return self.rawValue
    }
}

public enum Type2: String, CustomStringConvertible {
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

public enum ListType: String, CustomStringConvertible {
    case all
    case personal
    case official
    case watchlists

    public var description: String {
        return self.rawValue
    }
}

public enum ListSortType: String, CustomStringConvertible {
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
public enum CommentType: String {
    case all = "all"
    case reviews = "reviews"
    case shouts = "shouts"
}

/// Extended information
public enum ExtendedType: String, CustomStringConvertible {
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
public enum ListItemType: String {
    case movies
    case shows
    case seasons
    case episodes
    case people
}

public enum Period: String {
    case Weekly = "weekly"
    case Monthly = "monthly"
    case All = "all"
}

public enum SectionType: String {
    case Calendar = "calendar"
    case ProgressWatched = "progress_watched"
    case ProgressCollected = "progress_collected"
    case Recommendations = "recommendations"
}

public enum HiddenItemsType: String {
    case Movie = "movie"
    case Show = "show"
    case Season = "Season"
}

public enum LikeType: String {
    case Comments = "comments"
    case Lists = "lists"
}
