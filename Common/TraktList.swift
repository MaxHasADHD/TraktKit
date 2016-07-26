//
//  TraktList.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktList: TraktProtocol {
    
    public let allowComments: Bool
    public let commentCount: NSNumber
    public let createdAt: Date
    public let description: String
    public let displayNumbers: Bool
    public var itemCount: NSNumber
    public var likes: NSNumber
    public let name: String
    public let privacy: String // TODO: Maybe make a type?
    public var updatedAt: Date
    
    public let id: ID
    
    // Initialization
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let name = json["name"] as? String,
            let description = json["description"] as? String,
            let privacy = json["privacy"] as? String,
            let displayNumbers = json["display_numbers"] as? Bool,
            let allowComments = json["allow_comments"] as? Bool,
            let createdAt = Date.dateFromString(json["created_at"]),
            let updatedAt = Date.dateFromString(json["updated_at"]),
            let itemCount = json["item_count"] as? NSNumber,
            let commentCount = json["comment_count"] as? NSNumber,
            let likes = json["likes"] as? NSNumber,
            let id = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        self.name               = name
        self.description        = description
        self.privacy            = privacy
        self.displayNumbers     = displayNumbers
        self.allowComments      = allowComments
        self.createdAt          = createdAt
        self.updatedAt          = updatedAt
        self.itemCount          = itemCount
        self.commentCount       = commentCount
        self.likes              = likes
        self.id                 = id
    }
}
