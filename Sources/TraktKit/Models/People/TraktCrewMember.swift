//
//  TraktCrewMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Cast member for (show/season/episode)/people API
public struct TVCrewMember: TraktObject {
    public let jobs: [String]
    /// Not available for /episodes/{number}/people
    public let episodeCount: Int?
    public let person: Person
    
    enum CodingKeys: String, CodingKey {
        case jobs
        case episodeCount = "episode_count"
        case person
    }
}

/// Cast member for /movies/.../people API
public struct MovieCrewMember: TraktObject {
    public let jobs: [String]
    public let person: Person
}

/// Cast member for /people/.../shows API
public struct PeopleTVCrewMember: TraktObject {
    public let jobs: [String]
    public let episodeCount: Int
    public let show: TraktShow
    
    enum CodingKeys: String, CodingKey {
        case jobs
        case episodeCount = "episode_count"
        case show
    }
}


/// Cast member for /people/.../movies API
public struct PeopleMovieCrewMember: TraktObject {
    public let jobs: [String]
    public let movie: TraktMovie
    
    enum CodingKeys: String, CodingKey {
        case jobs
        case movie
    }
}
