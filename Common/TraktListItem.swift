//
//  TraktListItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/22/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktListItem: TraktProtocol {
    
    public let rank: NSNumber
    public let listedAt: NSDate
    public let type: String
    public var show: TraktShow? = nil
    public var season: TraktSeason? = nil
    public var episode: TraktEpisode? = nil
    public var movie: TraktMovie? = nil
    public var person: Person? = nil
    
    // Initialization
    public init?(json: RawJSON?) {
        guard let json = json,
            rank = json["rank"] as? NSNumber,
            listedAt = NSDate.dateFromString(json["listed_at"]),
            type = json["type"] as? String else { return nil }
        
        self.rank = rank
        self.listedAt = listedAt
        self.type = type
        
        if type == "movie" {
            guard let movie = TraktMovie(json: json["movie"] as? RawJSON) else { return nil }
            self.movie = movie
        }
        else if type == "show" {
            guard let show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
            
            self.show = show
        }
        else if type == "season" {
            guard let show = TraktShow(json: json["show"] as? RawJSON),
                season = TraktSeason(json: json["season"] as? RawJSON) else { return nil }
            
            self.show = show
            self.season = season
        }
        else if type == "episode" {
            guard let show = TraktShow(json: json["show"] as? RawJSON),
                episode = TraktEpisode(json: json["episode"] as? RawJSON) else { return nil }
            
            self.show = show
            self.episode = episode
        }
        else if type == "person" {
            guard let person = Person(json: json["person"] as? RawJSON) else { return nil }
            
            self.person = person
        }
        else {
            return nil
        }
        
    }
}
