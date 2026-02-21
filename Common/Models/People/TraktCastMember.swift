//
//  TraktCastMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Cast member for (show/season/episode)/.../people API
public struct TVCastMember: TraktObject {
    public let characters: [String]
    /// Not available for /episodes/{number}/people
    public let episodeCount: Int?
    public let person: Person
    
    enum CodingKeys: String, CodingKey {
        case characters
        case episodeCount = "episode_count"
        case person
    }
}

/// Cast member for /movies/.../people API
public struct MovieCastMember: TraktObject {
    public let characters: [String]
    public let person: Person
}

/// Cast member for /people/.../shows API
public struct PeopleTVCastMember: TraktObject {
    public let characters: [String]
    public let episodeCount: Int
    public let seriesRegular: Bool
    public let show: TraktShow
    
    enum CodingKeys: String, CodingKey {
        case characters
        case episodeCount = "episode_count"
        case seriesRegular = "series_regular"
        case show
    }
}

/// Cast member for /people/.../movies API
public struct PeopleMovieCastMember: TraktObject {
    public let characters: [String]
    public let movie: TraktMovie
    
    enum CodingKeys: String, CodingKey {
        case characters
        case movie
    }
}
