//
//  TraktPerson.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

// Actor/Actress/Crew member
public struct Person: Codable {
    // Extended: Min
    public let name: String
    public let ids: ID
    
    // Extended: Full
    public let biography: String?
    public let birthday: Date?
    public let death: Date?
    public let birthplace: String?
    public let homepage: URL?
}
