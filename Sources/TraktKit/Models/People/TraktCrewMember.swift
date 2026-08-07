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
    /// Trakt sends the singular alongside `jobs`; it is the headline job when there are several.
    public let job: String?
    public let jobs: [String]
    public let episodeCount: Int?
    public let images: TraktImages?
    public let person: Person

    enum CodingKeys: String, CodingKey {
        case job
        case jobs
        case episodeCount = "episode_count"
        case images
        case person
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        job = try container.decodeIfPresent(String.self, forKey: .job)
        jobs = try container.decodeIfPresent([String].self, forKey: .jobs) ?? []
        episodeCount = try container.decodeIfPresent(Int.self, forKey: .episodeCount)
        images = try? container.decodeIfPresent(TraktImages.self, forKey: .images)
        person = try container.decode(Person.self, forKey: .person)
    }
}

/// Cast member for /movies/.../people API
public struct MovieCrewMember: TraktObject {
    public let jobs: [String]
    public let person: Person
}

/// Cast member for /people/.../shows API
public struct PeopleTVCrewMember: TraktObject {
    public let job: String?
    public let jobs: [String]
    /// Trakt stopped sending `episode_count` on person→crew credits entirely. It was required here,
    /// so every response containing a single crew credit threw — taking the person's cast credits
    /// with it.
    public let episodeCount: Int?
    public let show: TraktShow

    enum CodingKeys: String, CodingKey {
        case job
        case jobs
        case episodeCount = "episode_count"
        case show
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        job = try container.decodeIfPresent(String.self, forKey: .job)
        jobs = try container.decodeIfPresent([String].self, forKey: .jobs) ?? []
        episodeCount = try container.decodeIfPresent(Int.self, forKey: .episodeCount)
        show = try container.decode(TraktShow.self, forKey: .show)
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
