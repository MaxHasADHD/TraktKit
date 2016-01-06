//
//  Structures.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/4/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
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

public struct Person {
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
    public let homepage: String? // TODO: Make NSURL
    
    // Initialize
    init(json: [String: AnyObject]) {
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
        homepage = json["homepage"] as? String
    }
}

public struct CrewMember {
    public let job: String
    public let person: Person
    
    init(json: [String: AnyObject]) {
        job = json["job"] as? String ?? ""
        person = Person(json: json["person"] as! [String: AnyObject])
    }
}

public struct CastMember {
    public let character: String
    public let person: Person
    
    init(json: [String: AnyObject]) {
        character = json["character"] as? String ?? ""
        person = Person(json: json["person"] as! [String: AnyObject])
    }
}
