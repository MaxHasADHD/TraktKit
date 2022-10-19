//
//  TraktCrewMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Cast member for (show/season/episode)/people API
public struct TVCrewMember: Codable, Hashable {
    public let jobs: [String]
    @available(*, deprecated, renamed: "jobs")
    public let job: String
    /// Not available for /episodes/{number}/people
    public let episodeCount: Int?
    public let person: Person
    
    enum CodingKeys: String, CodingKey {
        case jobs
        case job
        case episodeCount = "episode_count"
        case person
    }
}

/// Cast member for /movies/.../people API
public struct MovieCrewMember: Codable, Hashable {
    public let jobs: [String]
    @available(*, deprecated, renamed: "jobs")
    public let job: String
    public let person: Person
    
    enum CodingKeys: String, CodingKey {
        case jobs
        case job
        case person
    }
}

/// Cast member for /people/.../shows API
public struct PeopleTVCrewMember: Codable, Hashable {
    public let jobs: [String]
    @available(*, deprecated, renamed: "jobs")
    public let job: String
    public let episodeCount: Int
    public let show: TraktShow
    
    enum CodingKeys: String, CodingKey {
        case jobs
        case job
        case episodeCount = "episode_count"
        case show
    }
}


/// Cast member for /people/.../movies API
public struct PeopleMovieCrewMember: Codable, Hashable {
    public let jobs: [String]
    @available(*, deprecated, renamed: "jobs")
    public let job: String
    public let movie: TraktMovie
    
    enum CodingKeys: String, CodingKey {
        case jobs
        case job
        case movie
    }
}
