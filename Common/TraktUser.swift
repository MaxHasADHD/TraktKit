//
//  TraktUser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct User: Codable {
    public let username: String?
    public let isPrivate: Bool
    public let name: String?
    public let isVIP: Bool
    public let isVIPEP: Bool
    
    enum CodingKeys: String, CodingKey {
        case username
        case isPrivate = "private"
        case name
        case isVIP = "vip"
        case isVIPEP = "vip_ep"
    }
}

/// User object returned from User Settings
public struct SettingsUser: Codable {
    public let username: String?
    public let isPrivate: Bool
    public let name: String?
    public let isVIP: Bool
    public let isVIPEP: Bool
    public let joinedAt: Date
    public let location: String
    public let about: String
    public let gender: String
    public let age: Int
    public let vipOG: Bool
    public let vipYears: Int
    
    enum CodingKeys: String, CodingKey {
        case username
        case isPrivate = "private"
        case name
        case isVIP = "vip"
        case isVIPEP = "vip_ep"
        case joinedAt = "joined_at"
        case location
        case about
        case gender
        case age
        case vipOG = "vip_og"
        case vipYears = "vip_years"
    }
}
