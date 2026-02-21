//
//  TraktComment.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Comment: TraktObject {
    public let id: Int
    public var comment: String
    public let spoiler: Bool
    public let review: Bool
    public let parentId: Int
    public let createdAt: Date
    public let updatedAt: Date?
    public let replies: Int
    public let likes: Int
    public let userRating: Int?
    public let userStats: UserStats
    public let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case comment
        case spoiler
        case review
        case parentId = "parent_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case replies
        case likes
        case userRating = "user_rating"
        case userStats = "user_stats"
        case user
    }

    public struct UserStats: TraktObject {
        public let rating: Int?
        public let playCount: Int
        public let completedCount: Int

        enum CodingKeys: String, CodingKey {
            case rating
            case playCount = "play_count"
            case completedCount = "completed_count"
        }
    }
}

public struct TraktCommentPostBody: EncodableTraktObject {
    public let movie: SyncId?
    public let show: SyncId?
    public let season: SyncId?
    public let episode: SyncId?
    public let list: SyncId?
    public let comment: String
    public let spoiler: Bool?

    enum CodingKeys: String, CodingKey {
        case movie
        case show
        case season
        case episode
        case list
        case comment
        case spoiler
    }

    public init(
        movie: SyncId? = nil,
        show: SyncId? = nil,
        season: SyncId? = nil,
        episode: SyncId? = nil,
        list: SyncId? = nil,
        comment: String,
        spoiler: Bool? = nil
    ) {
        self.movie = movie
        self.show = show
        self.season = season
        self.episode = episode
        self.list = list
        self.comment = comment
        self.spoiler = spoiler
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
