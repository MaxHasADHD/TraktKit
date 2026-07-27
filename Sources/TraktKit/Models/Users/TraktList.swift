//
//  TraktList.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public enum ListPrivacy: String, TraktObject {
    /// Only you can see the list.
    case `private`
    /// Anyone with the `share_link` can see the list.
    case link
    /// Only your friends can see the list.
    case friends
    /// Anyone can see the list.
    case `public`
}

public struct TraktNewList: TraktObject {
    public let name: String
    public let description: String?
    public let privacy: ListPrivacy?
    public let displayNumbers: Bool?
    public let allowComments: Bool?
    public let sortBy: String?
    public let sortHow: String?

    public init(
        name: String,
        description: String? = nil,
        privacy: ListPrivacy? = nil,
        displayNumbers: Bool? = nil,
        allowComments: Bool? = nil,
        sortBy: String? = nil,
        sortHow: String? = nil
    ) {
        self.name = name
        self.description = description
        self.privacy = privacy
        self.displayNumbers = displayNumbers
        self.allowComments = allowComments
        self.sortBy = sortBy
        self.sortHow = sortHow
    }

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case privacy
        case displayNumbers = "display_numbers"
        case allowComments = "allow_comments"
        case sortBy = "sort_by"
        case sortHow = "sort_how"
    }
}

public struct TraktUpdateList: TraktObject {
    public let name: String?
    public let description: String?
    public let privacy: ListPrivacy?
    public let displayNumbers: Bool?
    public let allowComments: Bool?
    public let sortBy: String?
    public let sortHow: String?

    public init(
        name: String? = nil,
        description: String? = nil,
        privacy: ListPrivacy? = nil,
        displayNumbers: Bool? = nil,
        allowComments: Bool? = nil,
        sortBy: String? = nil,
        sortHow: String? = nil
    ) {
        self.name = name
        self.description = description
        self.privacy = privacy
        self.displayNumbers = displayNumbers
        self.allowComments = allowComments
        self.sortBy = sortBy
        self.sortHow = sortHow
    }

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case privacy
        case displayNumbers = "display_numbers"
        case allowComments = "allow_comments"
        case sortBy = "sort_by"
        case sortHow = "sort_how"
    }
}

public struct TraktList: TraktObject {
    public let allowComments: Bool
    public let commentCount: Int
    public let createdAt: Date?
    public let description: String?
    public let displayNumbers: Bool
    public var itemCount: Int
    public var likes: Int
    public let name: String
    public let privacy: ListPrivacy
    public let updatedAt: Date
    public let ids: ListId
    /// The list's owner. Returned by every list-reading endpoint (search, trending, popular, a
    /// user's lists, list summary); optional defensively for write-style responses. Note that
    /// Trakt's *official* lists are owned by a placeholder account whose `ids.slug` is `null` —
    /// such lists can only be addressed by list id, never as `users/{slug}/lists/{list}`.
    public let user: User?

    enum CodingKeys: String, CodingKey {
        case allowComments = "allow_comments"
        case commentCount = "comment_count"
        case createdAt = "created_at"
        case description
        case displayNumbers = "display_numbers"
        case itemCount = "item_count"
        case likes
        case name
        case privacy
        case updatedAt = "updated_at"
        case ids
        case user
    }
}

public struct TraktTrendingList: TraktObject {
    public let likeCount: Int
    public let commentCount: Int
    public let list: TraktList

    enum CodingKeys: String, CodingKey {
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case list
    }
}

public struct TraktReorderListsResponse: TraktObject {
    public let updated: Int
    public let skipped: [Int]

    enum CodingKeys: String, CodingKey {
        case updated
        case skipped = "skipped_ids"
    }
}
