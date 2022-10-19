//
//  TraktCastMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Cast member for (show/season/episode)/.../people API
public struct TVCastMember: Codable, Hashable {
    public let characters: [String]
    @available(*, deprecated, renamed: "characters")
    public let character: String
    /// Not available for /episodes/{number}/people
    public let episodeCount: Int?
    public let person: Person
    
    enum CodingKeys: String, CodingKey {
        case characters
        case character
        case episodeCount = "episode_count"
        case person
    }
}

/// Cast member for /movies/.../people API
public struct MovieCastMember: Codable, Hashable {
    public let characters: [String]
    @available(*, deprecated, renamed: "characters")
    public let character: String
    public let person: Person
    
    enum CodingKeys: String, CodingKey {
        case characters
        case character
        case person
    }
}

/// Cast member for /people/.../shows API
public struct PeopleTVCastMember: Codable, Hashable {
    public let characters: [String]
    @available(*, deprecated, renamed: "characters")
    public let character: String
    public let episodeCount: Int
    public let seriesRegular: Bool
    public let show: TraktShow
    
    enum CodingKeys: String, CodingKey {
        case characters
        case character
        case episodeCount = "episode_count"
        case seriesRegular = "series_regular"
        case show
    }
}

/// Cast member for /people/.../movies API
public struct PeopleMovieCastMember: Codable, Hashable {
    public let characters: [String]
    @available(*, deprecated, renamed: "characters")
    public let character: String
    public let movie: TraktMovie
    
    enum CodingKeys: String, CodingKey {
        case characters
        case character
        case movie
    }
}
