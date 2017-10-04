//
//  Likes.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Like: Codable {
    public let likedAt: Date
    public let type: LikeType
    public let list: TraktList?
    public let comment: Comment?
    
    public enum LikeType: String, Codable {
        case comment
        case list
    }
}
