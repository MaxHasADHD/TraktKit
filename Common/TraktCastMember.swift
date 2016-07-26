//
//  TraktCastMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CastMember: TraktProtocol {
    public let character: String
    public let person: Person?
    public let movie: TraktMovie?
    public let show: TraktShow?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let character = json["character"] as? String else { return nil }
        
        self.character = character
        self.person = Person(json: json["person"] as? RawJSON)
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
    }
}
