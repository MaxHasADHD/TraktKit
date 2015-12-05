//
//  SharedFunctions.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/27/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct User {
    public let username: String
    public let isPrivate: Bool
    public let name: String
    public let isVIP: Bool
    public let isVIPEP: Bool
    
    init(json: [String: AnyObject]) {
        username = json["username"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        isPrivate = json["private"] as? Bool ?? false
        name = json["name"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        isVIP = json["vip"] as? Bool ?? false
        isVIPEP = json["vip_ep"] as? Bool ?? false
    }
}

public struct Comment {
    public let id: NSNumber
    public let parentID: NSNumber
    public let createdAt: String // TODO: Make NSDate
    public let comment: String
    public let spoiler: Bool
    public let review: Bool
    public let replies: NSNumber
    public let userRating: NSNumber
    public let user: User
    
    init(json: [String: AnyObject]) {
        
        id = json["id"] as? NSNumber ?? 0
        parentID = json["parent_id"] as? NSNumber ?? 0
        createdAt = json["created_at"] as? String ?? ""
        comment = json["comment"] as? String ?? NSLocalizedString("COMMENTS_UNAVAILABLE", comment: "Comment Unavailable")
        spoiler = json["spoiler"] as? Bool ?? false
        review = json["review"] as? Bool ?? false
        replies = json["replies"] as? NSNumber ?? 0
        userRating = json["user_rating"] as? NSNumber ?? 0
        user = User(json: json["user"] as! [String: AnyObject])
    }
}

private typealias ShowsAndMovies = TraktManager
internal extension ShowsAndMovies {
    
    // MARK: - Trending
    
    func getTrending(type: WatchedType, page: Int, limit: Int, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/trending?page=\(page)&limit=\(limit)&extended=full,images", authorization: false, HTTPMethod: "GET") else { return nil }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Popular
    
    func getPopular(type: WatchedType, page: Int, limit: Int, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/popular?page=\(page)&limit=\(limit)&extended=full,images", authorization: false, HTTPMethod: "GET") else { return nil }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Played
    
    func getPlayed(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/played/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Watched
    
    func getWatched(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/watched/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Collected
    
    func getCollected(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/collected/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Anticipated
    
    func getAnticipated(type: WatchedType, page: Int, limit: Int, period: Period = .Weekly, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/anticipated/\(period.rawValue)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Updates
    
    func getUpdated(type: WatchedType, page: Int, limit: Int, startDate: String, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/updates/\(startDate)?page=\(page)&limit=\(limit)", authorization: false, HTTPMethod: "GET") else {
            return nil
        }
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Summary
    
    func getSummary<T: CustomStringConvertible>(type: WatchedType, id: T, extended: extendedType = .Min, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)?extended=\(extended.rawValue)", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Aliases
    
    func getAliases<T: CustomStringConvertible>(type: WatchedType, id: T, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Translations
    
    func getTranslations<T: CustomStringConvertible>(type: WatchedType, id: T, language: String?, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        var path = "\(type)/\(id)/translations"
        if let language = language {
            path += "/\(language)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Comments
    
    func getComments<T: CustomStringConvertible>(type: WatchedType, id: T, completion: commentsCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/comments", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - People
    
    func getPeople<T: CustomStringConvertible>(type: WatchedType, id: T, extended: extendedType = .Min, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/people?extended=\(extended.rawValue)", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Ratings
    
    func getRatings<T: CustomStringConvertible>(type: WatchedType, id: T, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/ratings", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Related
    
    func getRelated<T: CustomStringConvertible>(type: WatchedType, id: T, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/related", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Stats
    
    func getStatistics<T: CustomStringConvertible>(type: WatchedType, id: T, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/stats", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Watching
    
    func getUsersWatching<T: CustomStringConvertible>(type: WatchedType, id: T, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("\(type)/\(id)/watching", authorization: false, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
}