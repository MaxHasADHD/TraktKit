//
//  TraktComment.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Comment: TraktProtocol {
    public let id: NSNumber
    public let parentID: NSNumber
    public let createdAt: Date // TODO: Make Date
    public let comment: String
    public let spoiler: Bool
    public let review: Bool
    public let replies: NSNumber
    public let userRating: NSNumber
    public let user: User
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let id = json["id"] as? NSNumber,
            let parentID = json["parent_id"] as? NSNumber,
            let createdAt = Date.dateFromString(json["created_at"] as? String),
            let comment = json["comment"] as? String,
            let spoiler = json["spoiler"] as? Bool,
            let review = json["review"] as? Bool,
            let replies = json["replies"] as? NSNumber,
            let userRating = json["user_rating"] as? NSNumber,
            let user = User(json: json["user"] as? RawJSON) else { return nil }
        
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
