//
//  TraktComment.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Comment: Codable {
    public let id: Int
    public let parentId: Int
    public let createdAt: Date
    public var comment: String
    public let spoiler: Bool
    public let review: Bool
    public let replies: Int
    public let likes: Int
    public let userRating: Int?
    public let user: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case createdAt = "created_at"
        case comment
        case spoiler
        case review
        case replies
        case likes
        case userRating = "user_rating"
        case user
    }
}

public extension Sequence where Iterator.Element == Comment {
    func hideSpoilers() -> [Comment] {
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
