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
    public let person: Person?
    public let movie: TraktMovie?
    public let show: TraktShow?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let job = json["job"] as? String else { return nil }
        
        self.job = job
        self.person = Person(json: json["person"] as? RawJSON)
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
    }
}
