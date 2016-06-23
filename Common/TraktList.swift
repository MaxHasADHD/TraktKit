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
    public let createdAt: NSDate
    public let description: String
    public let displayNumbers: Bool
    public var itemCount: NSNumber
    public var likes: NSNumber
    public let name: String
    public let privacy: String // TODO: Maybe make a type?
    public var updatedAt: NSDate
    
    public let id: ID
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            name = json["name"] as? String,
            description = json["description"] as? String,
            privacy = json["privacy"] as? String,
            displayNumbers = json["display_numbers"] as? Bool,
            allowComments = json["allow_comments"] as? Bool,
            createdAt = NSDate.dateFromString(json["created_at"]),
            updatedAt = NSDate.dateFromString(json["updated_at"]),
            itemCount = json["item_count"] as? NSNumber,
            commentCount = json["comment_count"] as? NSNumber,
            likes = json["likes"] as? NSNumber,
            id = ID(json: json["ids"] as? RawJSON)
            else { return nil }
        
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
