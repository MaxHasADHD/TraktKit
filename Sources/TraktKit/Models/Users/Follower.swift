//
//  Follower.swift
//  TraktKit
//
//  Created by Claude Code on 2/21/26.
//

import Foundation

public struct Follower: TraktObject {
    public let followedAt: Date
    public let user: User

    enum CodingKeys: String, CodingKey {
        case followedAt = "followed_at"
        case user
    }
}
