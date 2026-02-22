//
//  TraktNote.swift
//  TraktKit
//

import Foundation

public struct TraktNote: TraktObject {
    public let id: Int
    public let notes: String
    public let privacy: String
    public let spoiler: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case notes
        case privacy
        case spoiler
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case user
    }
}

public struct TraktNoteBody: TraktObject {
    public let movie: SyncId?
    public let show: SyncId?
    public let season: SyncId?
    public let episode: SyncId?
    public let person: SyncId?
    public let notes: String
    public let privacy: String?
    public let spoiler: Bool?
    public let attachedTo: AttachedTo?

    enum CodingKeys: String, CodingKey {
        case movie
        case show
        case season
        case episode
        case person
        case notes
        case privacy
        case spoiler
        case attachedTo = "attached_to"
    }

    public struct AttachedTo: TraktObject {
        public let type: String
        public let id: Int?

        enum CodingKeys: String, CodingKey {
            case type
            case id
        }

        public init(type: String, id: Int? = nil) {
            self.type = type
            self.id = id
        }
    }

    public init(
        movie: SyncId? = nil,
        show: SyncId? = nil,
        season: SyncId? = nil,
        episode: SyncId? = nil,
        person: SyncId? = nil,
        notes: String,
        privacy: String? = nil,
        spoiler: Bool? = nil,
        attachedTo: AttachedTo? = nil
    ) {
        self.movie = movie
        self.show = show
        self.season = season
        self.episode = episode
        self.person = person
        self.notes = notes
        self.privacy = privacy
        self.spoiler = spoiler
        self.attachedTo = attachedTo
    }
}

public struct TraktNoteItem: TraktObject {
    public let attachedTo: AttachedTo?
    public let note: TraktNote
    public let type: String
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let season: TraktSeason?
    public let episode: TraktEpisode?
    public let person: Person?

    enum CodingKeys: String, CodingKey {
        case attachedTo = "attached_to"
        case note
        case type
        case movie
        case show
        case season
        case episode
        case person
    }

    public struct AttachedTo: TraktObject {
        public let type: String
        public let id: Int?

        enum CodingKeys: String, CodingKey {
            case type
            case id
        }
    }
}
