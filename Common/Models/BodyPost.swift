//
//  BodyPost.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 11/7/20.
//  Copyright © 2020 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Body data for endpoints like `/sync/history` that contains Trakt Ids.
struct TraktMediaBody<ID: Encodable>: Encodable {
    let movies: [ID]?
    let shows: [ID]?
    let seasons: [ID]?
    let episodes: [ID]?
    let ids: [Int]?
    let people: [ID]?
    
    init(movies: [ID]? = nil, shows: [ID]? = nil, seasons: [ID]? = nil, episodes: [ID]? = nil, ids: [Int]? = nil, people: [ID]? = nil) {
        self.movies = movies
        self.shows = shows
        self.seasons = seasons
        self.episodes = episodes
        self.ids = ids
        self.people = people
    }
}

/// Data for containing a single object
class TraktSingleObjectBody<ID: Encodable>: Encodable {
    let movie: ID?
    let show: ID?
    let season: ID?
    let episode: ID?
    let list: ID?
    
    init(movie: ID? = nil, show: ID? = nil, season: ID? = nil, episode: ID? = nil, list: ID? = nil) {
        self.movie = movie
        self.show = show
        self.season = season
        self.episode = episode
        self.list = list
    }
}

class TraktCommentBody: TraktSingleObjectBody<SyncId> {
    let comment: String
    let spoiler: Bool?
    
    init(movie: SyncId? = nil, show: SyncId? = nil, season: SyncId? = nil, episode: SyncId? = nil, list: SyncId? = nil, comment: String, spoiler: Bool?) {
        self.comment = comment
        self.spoiler = spoiler
        super.init(movie: movie, show: show, season: season, episode: episode, list: list)
    }
}

/// ID used to sync with Trakt.
public struct SyncId: Codable, Hashable {
    /// Trakt id of the movie / show / season / episode
    public let trakt: Int
    
    enum CodingKeys: String, CodingKey {
        case ids
    }
    
    enum IDCodingKeys: String, CodingKey {
        case trakt
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nested = container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .ids)
        try nested.encode(trakt, forKey: .trakt)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nested = try container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .ids)
        self.trakt = try nested.decode(Int.self, forKey: .trakt)
    }
    
    public init(trakt: Int) {
        self.trakt = trakt
    }
}

public struct AddToHistoryId: Encodable, Hashable {
    /// Trakt id of the movie / show / season / episode
    public let trakt: Int
    /// UTC datetime when the item was watched.
    public let watchedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case ids, watchedAt = "watched_at"
    }
    
    enum IDCodingKeys: String, CodingKey {
        case trakt
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nested = container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .ids)
        try nested.encode(trakt, forKey: .trakt)
        try container.encodeIfPresent(watchedAt, forKey: .watchedAt)
    }
    
    public init(trakt: Int, watchedAt: Date?) {
        self.trakt = trakt
        self.watchedAt = watchedAt
    }
}

public struct RatingId: Encodable, Hashable {
    /// Trakt id of the movie / show / season / episode
    public let trakt: Int
    /// Between 1 and 10.
    public let rating: Int
    /// UTC datetime when the item was rated.
    public let ratedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case ids, rating, ratedAt = "rated_at"
    }
    
    enum IDCodingKeys: String, CodingKey {
        case trakt
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nested = container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .ids)
        try nested.encode(trakt, forKey: .trakt)
        try container.encode(rating, forKey: .rating)
        try container.encodeIfPresent(ratedAt, forKey: .ratedAt)
    }
    
    public init(trakt: Int, rating: Int, ratedAt: Date?) {
        self.trakt = trakt
        self.rating = rating
        self.ratedAt = ratedAt
    }
}

public struct CollectionId: Encodable, Hashable {
    /// Trakt id of the movie / show / season / episode
    public let trakt: Int
    /// UTC datetime when the item was collected. Set to `released` to automatically use the inital release date.
    public let collectedAt: Date
    public let mediaType: TraktCollectedItem.MediaType?
    public let resolution: TraktCollectedItem.Resolution?
    public let hdr: TraktCollectedItem.HDR?
    public let audio: TraktCollectedItem.Audio?
    public let audioChannels: TraktCollectedItem.AudioChannels?
    /// Set true if in 3D.
    public let is3D: Bool?
    
    enum CodingKeys: String, CodingKey {
        case ids
        case collectedAt = "collected_at"
        case mediaType = "media_type"
        case resolution
        case hdr
        case audio
        case audioChannels = "audio_channels"
        case is3D = "3d"
    }
    
    enum IDCodingKeys: String, CodingKey {
        case trakt
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nested = container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .ids)
        try nested.encode(trakt, forKey: .trakt)
        try container.encode(collectedAt, forKey: .collectedAt)
        try container.encodeIfPresent(mediaType, forKey: .mediaType)
        try container.encodeIfPresent(resolution, forKey: .resolution)
        try container.encodeIfPresent(hdr, forKey: .hdr)
        try container.encodeIfPresent(audio, forKey: .audio)
        try container.encodeIfPresent(audioChannels, forKey: .audioChannels)
        try container.encodeIfPresent(is3D, forKey: .is3D)
    }
    
    public init(trakt: Int, collectedAt: Date, mediaType: TraktCollectedItem.MediaType? = nil, resolution: TraktCollectedItem.Resolution? = nil, hdr: TraktCollectedItem.HDR? = nil, audio: TraktCollectedItem.Audio? = nil, audioChannels: TraktCollectedItem.AudioChannels? = nil, is3D: Bool? = nil) {
        self.trakt = trakt
        self.collectedAt = collectedAt
        self.mediaType = mediaType
        self.resolution = resolution
        self.hdr = hdr
        self.audio = audio
        self.audioChannels = audioChannels
        self.is3D = is3D
    }
}
