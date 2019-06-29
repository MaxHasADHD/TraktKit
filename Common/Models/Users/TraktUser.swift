//
//  TraktUser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct User: Codable {
    
    // Min
    public let username: String?
    public let isPrivate: Bool
    public let name: String?
    public let isVIP: Bool?
    public let isVIPEP: Bool?
    //    public let ids: ID
    
    // Full
    public let joinedAt: Date?
    public let location: String?
    public let about: String?
    public let gender: String?
    public let age: Int?
    public let images: ImagesType?
    
    // VIP
    public let vipOG: Bool?
    public let vipYears: Int?
    
    enum CodingKeys: String, CodingKey {
        case username
        case isPrivate = "private"
        case name
        case isVIP = "vip"
        case isVIPEP = "vip_ep"
        //        case ids
        
        case joinedAt = "joined_at"
        case location
        case about
        case gender
        case age
        case images = "images"
        case vipOG = "vip_og"
        case vipYears = "vip_years"
    }
}

// MARK: URL for user avatar is quite nested
public struct ImagesType: Codable {
    public let avatar: AvatarType?
    
    enum CodingKeys: String, CodingKey {
        case avatar
    }
}

public struct AvatarType: Codable {
    public let urlString: String?
    
    enum CodingKeys: String, CodingKey {
        case urlString = "full"
    }
}

