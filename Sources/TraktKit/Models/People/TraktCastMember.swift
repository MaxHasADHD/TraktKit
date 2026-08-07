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
    /// Trakt sends the singular alongside `characters`; it is the primary billing when there are
    /// several.
    public let character: String?
    public let characters: [String]
    public let episodeCount: Int?
    /// A sort key, not an index: values are sparse (`0,1,…,7,9,10,…`) and cast and guest stars share
    /// one namespace, so it orders a list but never indexes one.
    public let order: Int?
    public let images: TraktImages?
    public let person: Person

    enum CodingKeys: String, CodingKey {
        case character
        case characters
        case episodeCount = "episode_count"
        case order
        case images
        case person
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        character = try container.decodeIfPresent(String.self, forKey: .character)
        characters = try container.decodeIfPresent([String].self, forKey: .characters) ?? []
        episodeCount = try container.decodeIfPresent(Int.self, forKey: .episodeCount)
        order = try container.decodeIfPresent(Int.self, forKey: .order)
        images = try? container.decodeIfPresent(TraktImages.self, forKey: .images)
        person = try container.decode(Person.self, forKey: .person)
    }
}

/// Cast member for /movies/.../people API
public struct MovieCastMember: TraktObject {
    public let characters: [String]
    public let person: Person
}

/// Cast member for /people/.../shows API
public struct PeopleTVCastMember: TraktObject {
    public let character: String?
    public let characters: [String]
    public let episodeCount: Int?
    public let seriesRegular: Bool?
    public let show: TraktShow

    enum CodingKeys: String, CodingKey {
        case character
        case characters
        case episodeCount = "episode_count"
        case seriesRegular = "series_regular"
        case show
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        character = try container.decodeIfPresent(String.self, forKey: .character)
        characters = try container.decodeIfPresent([String].self, forKey: .characters) ?? []
        episodeCount = try container.decodeIfPresent(Int.self, forKey: .episodeCount)
        seriesRegular = try container.decodeIfPresent(Bool.self, forKey: .seriesRegular)
        show = try container.decode(TraktShow.self, forKey: .show)
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
