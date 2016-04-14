//
//  TraktCrewMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CrewMember: TraktProtocol {
    public let job: String
    public let person: Person
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            job = json["job"] as? String,
            person = Person(json: json["person"] as? RawJSON) else { return nil }
        
        self.job = job
        self.person = person
    }
}
