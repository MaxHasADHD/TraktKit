//
//  TraktPerson.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

// Actor/Actress/Crew member
public struct Person: TraktProtocol {
    // Extended: Min
    public let name: String
    public let ids: ID
    
    // Extended: Full
    public let biography: String?
    public let birthday: Date?
    public let death: Date?
    public let birthplace: String?
    public let homepage: URL?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let name = json["name"] as? String,
            !name.isEmpty,
            let ids = ID(json: json["ids"] as? [String: AnyObject]) else { return nil }
        
        // Extended: Min
        self.name = name
        self.ids = ids
        
        // Extended: Full
        biography   = json["biography"] as? String
        birthday    = Date.dateFromString(json["birthday"])
        death       = Date.dateFromString(json["death"])
        birthplace  = json["birthplace"] as? String
        homepage    = (json["homepage"] as? String)?.toURL()
    }
}
