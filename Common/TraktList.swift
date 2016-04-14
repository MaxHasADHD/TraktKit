//
//  TraktList.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktList: TraktProtocol {
    public let name: String
    public let description: String
    public let privacy: String // TODO: Maybe make a type?
    public let displayNumbers: Bool
    public let allowComments: Bool
    public let id: ID
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            name = json["name"] as? String,
            description = json["description"] as? String,
            privacy = json["privacy"] as? String,
            displayNumbers = json["display_numbers"] as? Bool,
            allowComments = json["allow_comments"] as? Bool,
            id = ID(json: json["ids"] as? RawJSON)
            else { return nil }
        
        self.name            = name
        self.description     = description
        self.privacy         = privacy
        self.displayNumbers  = displayNumbers
        self.allowComments   = allowComments
        self.id              = id
    }
}
