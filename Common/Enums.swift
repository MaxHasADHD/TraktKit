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
    /// Service Unavailable - server overloaded
    public static let ServiceOverloaded = 503
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError = 520
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError2 = 521
    /// Service Unavailable - Cloudflare error
    public static let CloudflareError3 = 522
}

/// What to search for
public enum SearchType: String {
    case movie
    case show
    case episode
    case person
    case list
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

/// Type of comments
public enum CommentType: String {
    case all = "all"
    case reviews = "reviews"
    case shouts = "shouts"
}

/// Extended information
/*public struct ExtendedType: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// Least amount of info
    public static let Min      = ExtendedType(rawValue: 0)
    /// Images for Show, Episode, or Movie
    public static let Images   = ExtendedType(rawValue: 1)
    /// All information, excluding images
    public static let Full     = ExtendedType(rawValue: 2)
    /// Collection only. Additional video and audio info.
    public static let Metadata = ExtendedType(rawValue: 3)
    /// Get all seasons and episodes
    public static let Episodes = ExtendedType(rawValue: 4)
    
    func value() -> String {
        switch self.rawValue {
        case 0:
            return "min"
        case 1:
            return "images"
        case 2:
            return "full"
        case 3:
            return "metadata"
        case 4:
            return "episodes"
        default:
            return ""
        }
    }
}*/

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
    
    public var description: String {
        get {
            return self.rawValue
        }
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
