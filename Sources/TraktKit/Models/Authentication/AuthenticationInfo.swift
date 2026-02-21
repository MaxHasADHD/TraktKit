//
//  AuthenticationInfo.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/7/19.
//  Copyright © 2019 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct AuthenticationInfo: TraktObject {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: TimeInterval
    public let refreshToken: String
    public let scope: String
    public let createdAt: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
    }
}
