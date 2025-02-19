//
//  FollowRequest.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct FollowRequest: TraktObject {
    public let id: Int
    public let requestedAt: Date
    public let user: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case requestedAt = "requested_at"
        case user
    }
}

public struct FollowResult: TraktObject {
    public let followedAt: Date
    public let user: User
    
    enum CodingKeys: String, CodingKey {
        case followedAt = "followed_at"
        case user
    }
}
