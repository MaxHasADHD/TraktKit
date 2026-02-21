//
//  AccountSettings.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct AccountSettings: TraktObject {
    public let user: User
    public let connections: Connections
    public let sharingText: SharingText
    public let limits: Limits

    enum CodingKeys: String, CodingKey {
        case user
        case connections
        case sharingText = "sharing_text"
        case limits
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
