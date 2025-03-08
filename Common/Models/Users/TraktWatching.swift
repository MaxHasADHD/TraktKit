//
//  TraktWatching.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/1/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public enum TraktWatching: TraktObject {
    case watching(WatchingItem)
    case notWatchingAnything

    public struct WatchingItem: TraktObject {
        public let expiresAt: Date
        public let startedAt: Date
        public let action: String
        public let mediaType: MediaType
        public let mediaItem: MediaItem

        public enum MediaType: String, TraktObject {
            case episode
            case movie
        }

        public enum MediaItem: TraktObject {
            case episode(TraktEpisode, show: TraktShow)
            case movie(TraktMovie)
        }
    }
}

extension TraktWatching {
    public init(from decoder: Decoder) throws {
        // First, try to decode as a watching item
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let expiresAt = try container.decode(Date.self, forKey: .expiresAt)
            let startedAt = try container.decode(Date.self, forKey: .startedAt)
            let action = try container.decode(String.self, forKey: .action)
            let typeString = try container.decode(String.self, forKey: .mediaType)

            guard let type = WatchingItem.MediaType(rawValue: typeString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .mediaType,
                    in: container,
                    debugDescription: "Invalid media type: \(typeString)"
                )
            }

            let item: WatchingItem.MediaItem

            switch type {
            case .episode:
                let episode = try container.decode(TraktEpisode.self, forKey: .episode)
                let show = try container.decode(TraktShow.self, forKey: .show)
                item = .episode(episode, show: show)

            case .movie:
                let movie = try container.decode(TraktMovie.self, forKey: .movie)
                item = .movie(movie)
            }

            let watchingItem = WatchingItem(
                expiresAt: expiresAt,
                startedAt: startedAt,
                action: action,
                mediaType: type,
                mediaItem: item
            )

            self = .watching(watchingItem)
        } catch {
            // If decode failed, check if this is due to a 204 response
            // This will be handled at the network layer, so here we'll
            // just create a placeholder for that case
            self = .notWatchingAnything
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .watching(let watchingItem):
            // Encode common properties
            try container.encode(watchingItem.expiresAt, forKey: .expiresAt)
            try container.encode(watchingItem.startedAt, forKey: .startedAt)
            try container.encode(watchingItem.action, forKey: .action)
            try container.encode(watchingItem.mediaType.rawValue, forKey: .mediaType)

            // Encode media-specific properties
            switch watchingItem.mediaItem {
            case .episode(let episode, let show):
                try container.encode(episode, forKey: .episode)
                try container.encode(show, forKey: .show)

            case .movie(let movie):
                try container.encode(movie, forKey: .movie)
            }

        case .notWatchingAnything:
            // For not watching, we'll encode a special marker
            // This isn't in the Trakt API but helps us identify this state when decoding our stored data
            try container.encodeNil(forKey: .expiresAt)
            try container.encodeNil(forKey: .startedAt)
            try container.encodeNil(forKey: .action)
            try container.encodeNil(forKey: .mediaType)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case startedAt = "started_at"
        case action
        case mediaType = "type"
        case episode
        case show
        case movie
    }
}

// Extension to add convenience accessors
extension TraktWatching {
    public var isWatching: Bool {
        switch self {
        case .watching:
            return true
        case .notWatchingAnything:
            return false
        }
    }

    public var mediaType: WatchingItem.MediaType? {
        switch self {
        case .watching(let item):
            return item.mediaType
        case .notWatchingAnything:
            return nil
        }
    }
}
