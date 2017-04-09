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
    public let createdAt: Date
    public var comment: String
    public let spoiler: Bool
    public let review: Bool
    public let replies: NSNumber
    public let userRating: NSNumber?
    public let user: User
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let id = json["id"] as? NSNumber,
            let parentID = json["parent_id"] as? NSNumber,
            let createdAt = Date.dateFromString(json["created_at"]),
            let comment = json["comment"] as? String,
            let spoiler = json["spoiler"] as? Bool,
            let review = json["review"] as? Bool,
            let replies = json["replies"] as? NSNumber,
            let user = User(json: json["user"] as? RawJSON) else { return nil }
        
        self.id = id
        self.parentID = parentID
        self.createdAt = createdAt
        self.comment = comment
        self.spoiler = spoiler
        self.review = review
        self.replies = replies
        self.userRating = json["user_rating"] as? NSNumber
        self.user = user
    }
}

public extension Sequence where Iterator.Element == Comment {
    public func hideSpoilers() -> [Comment] {
        var copy: [Comment] = self as! [Comment]
        
        for (index, var comment) in copy.enumerated() {
            var text = comment.comment
            
            if let start = text.range(of: "[spoiler]"),
                let end = text.range(of: "[/spoiler]") {
                
                let range = Range(uncheckedBounds: (start.lowerBound, end.upperBound))
                // Clean up title
                text.removeSubrange(range)
                comment.comment = text.trimmingCharacters(in: .whitespaces)
                copy[index] = comment
            }
        }
        return copy.filter { $0.spoiler == false }
    }
}
