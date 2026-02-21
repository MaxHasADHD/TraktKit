//
//  TraktCommentLikedUser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/24/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktCommentLikedUser: TraktObject {
    public let likedAt: Date
    public let user: User

    enum CodingKeys: String, CodingKey {
        case likedAt = "liked_at"
        case user
    }
}
