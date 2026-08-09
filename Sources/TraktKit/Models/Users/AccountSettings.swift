//
//  AccountSettings.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation
import os

public struct AccountSettings: TraktObject {
    public let user: User
    public let connections: Connections
    public let sharingText: SharingText
    /// Account limits (lists, watchlist, favorites, …).
    ///
    /// Trakt documents `limits` itself as nullable, and every limit inside it as
    /// required — which is why the members of ``Limits`` are non-optional.
    ///
    /// - Note: `nil` means "unknown", never "zero". Callers must not block a user
    ///   action on a missing limit.
    public let limits: Limits?

    enum CodingKeys: String, CodingKey {
        case user
        case connections
        case sharingText = "sharing_text"
        case limits
    }

    private static let logger = Logger(subsystem: "TraktKit", category: "AccountSettings")

    /// Decodes `limits` leniently: a payload that doesn't match the documented
    /// contract degrades to `nil` instead of failing the whole settings call.
    ///
    /// Trakt's limits schema is in flux — the published OpenAPI spec already omits
    /// keys the live API returns — so a "required" field can disappear without
    /// warning. Since `nil` already means "unknown, don't block", a drifted payload
    /// is better treated as an absent one than as a broken `/users/settings`
    /// response, which would take the user, connections and sharing text down with
    /// it. The lenient path is scoped to decoding failures of the `limits` sub-tree
    /// only; every other key still decodes strictly.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decode(User.self, forKey: .user)
        self.connections = try container.decode(Connections.self, forKey: .connections)
        self.sharingText = try container.decode(SharingText.self, forKey: .sharingText)

        do {
            // An absent or null key returns nil here without throwing, so a genuinely
            // limit-less response never reaches the catch below.
            self.limits = try container.decodeIfPresent(Limits.self, forKey: .limits)
        } catch let error as DecodingError {
            Self.logger.debug("Ignoring an undecodable `limits` object; treating account limits as unknown: \(error, privacy: .public)")
            self.limits = nil
        }
    }

    public struct Connections: TraktObject {
        public let facebook: Bool
        public let twitter: Bool
        public let mastodon: Bool
        public let google: Bool
        public let tumblr: Bool
        public let medium: Bool
        public let slack: Bool
        public let apple: Bool
        public let dropbox: Bool
        public let microsoft: Bool
    }

    public struct SharingText: TraktObject {
        public let watching: String?
        public let watched: String?
        public let rated: String?
    }

    /// When Trakt sends a `limits` object at all, every limit inside it is required,
    /// so these are non-optional. A response that breaks that contract is dropped
    /// wholesale — see ``AccountSettings/init(from:)``.
    public struct Limits: TraktObject {
        public let list: List
        public let watchlist: Watchlist
        public let favorites: Favorites
        public let search: Search
        public let collection: Collection
        public let notes: Notes

        public struct List: TraktObject {
            /// Total lists
            public let count: Int
            /// Item per list
            public let itemCount: Int

            enum CodingKeys: String, CodingKey {
                case count
                case itemCount = "item_count"
            }
        }

        public struct Watchlist: TraktObject {
            /// Number of items that can be added to the watchlist
            public let itemCount: Int

            enum CodingKeys: String, CodingKey {
                case itemCount = "item_count"
            }
        }

        public struct Favorites: TraktObject {
            /// Number of items that can be favorited.
            public let itemCount: Int

            enum CodingKeys: String, CodingKey {
                case itemCount = "item_count"
            }
        }

        public struct Search: TraktObject {
            /// Number of saved recent searches
            public let recentCount: Int

            enum CodingKeys: String, CodingKey {
                case recentCount = "recent_count"
            }
        }

        public struct Collection: TraktObject {
            /// Number of items that can be collected.
            public let itemCount: Int

            enum CodingKeys: String, CodingKey {
                case itemCount = "item_count"
            }
        }

        public struct Notes: TraktObject {
            /// Number of items that can have a personal note.
            public let itemCount: Int

            enum CodingKeys: String, CodingKey {
                case itemCount = "item_count"
            }
        }
    }
}
