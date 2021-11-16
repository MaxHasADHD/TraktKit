//
//  Friend.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/11/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Friend: Codable, Hashable {
    public let friendsAt: Date
    public let user: User
    
    enum CodingKeys: String, CodingKey {
        case friendsAt = "friends_at"
        case user
    }
}
