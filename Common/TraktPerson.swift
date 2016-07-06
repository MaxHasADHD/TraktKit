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
    public let birthday: NSDate?
    public let death: NSDate?
    public let birthplace: String?
    public let homepage: URL?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            name = json["name"] as? String,
            ids = ID(json: json["ids"] as? [String: AnyObject]) else { return nil }
        
        // Extended: Min
        self.name = name
        self.ids = ids
        
        // Extended: Full
        biography   = json["biography"] as? String
        birthday    = NSDate.dateFromString(json["birthday"] as? String)
        death       = NSDate.dateFromString(json["death"] as? String)
        birthplace  = json["birthplace"] as? String
        homepage    = (json["homepage"] as? String)?.toURL()
    
        // Extended: Images
        if let imageJSON = json["images"] as? RawJSON {
            images = TraktImages(json: imageJSON)
        } else {
            images = nil
        }
    }
}
