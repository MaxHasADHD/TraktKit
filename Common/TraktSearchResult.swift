//
//  TraktSearchResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktSearchResult: TraktProtocol {
    public let type: String // Can be movie, show, episode, person, list
    public let score: Double?
    
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let episode: TraktEpisode?
    public let person: Person?
    public let list: TraktList?
    
    // Initialize
    public init(type: String, score: Double, movie: TraktMovie?, show: TraktShow?, episode: TraktEpisode?, person: Person?, list: TraktList?) {
        self.type       = type
        self.score      = score
        self.movie      = movie
        self.show       = show
        self.episode    = episode
        self.person     = person
        self.list       = list
    }
    
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let type = json["type"] as? String else { return nil }
        
        self.type       = type
        self.score      = json["score"] as? Double
        self.movie      = TraktMovie(json: json["movie"] as? RawJSON)
        self.show       = TraktShow(json: json["show"] as? RawJSON)
        self.episode    = TraktEpisode(json: json["episode"] as? RawJSON)
        self.person     = Person(json: json["person"] as? RawJSON)
        self.list       = TraktList(json: json["list"] as? RawJSON)
    }
}
