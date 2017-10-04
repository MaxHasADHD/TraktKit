//
//  FollowUserResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/11/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct FollowUserResult: Codable {
    let approvedAt: Date
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case approvedAt = "approved_at"
        case user
    }
}
