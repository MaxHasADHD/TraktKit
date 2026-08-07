//
//  CastAndCrew.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CastAndCrew<Cast: TraktObject, Crew: TraktObject>: TraktObject {
    public let cast: [Cast]?
    public let guestStars: [Cast]?

    /// Every crew department Trakt returned, keyed by the raw department name.
    ///
    /// Decoded dynamically rather than against a fixed key list, because Trakt returns departments
    /// its own documentation omits: `created by` comes back from the show, season, episode and
    /// person endpoints while appearing in none of the docs, and a hardcoded list dropped it
    /// silently at decode time. Anything Trakt adds next arrives here instead of vanishing.
    public let crewByDepartment: [String: [Crew]]

    // MARK: - Named departments
    //
    // The departments observed in the wild, as accessors over the dictionary. Reading through
    // `crewByDepartment` keeps them from narrowing what is decoded — they are a convenience, not the
    // list of departments that exist.

    public var directors: [Crew]? { crewByDepartment[CrewKeys.directors.rawValue] }
    public var writers: [Crew]? { crewByDepartment[CrewKeys.writers.rawValue] }
    public var producers: [Crew]? { crewByDepartment[CrewKeys.producers.rawValue] }
    public var editors: [Crew]? { crewByDepartment[CrewKeys.editors.rawValue] }
    /// Costume & make-up
    public var costume: [Crew]? { crewByDepartment[CrewKeys.costume.rawValue] }
    public var sound: [Crew]? { crewByDepartment[CrewKeys.sound.rawValue] }
    public var art: [Crew]? { crewByDepartment[CrewKeys.art.rawValue] }
    public var visualEffects: [Crew]? { crewByDepartment[CrewKeys.visualEffects.rawValue] }
    public var camera: [Crew]? { crewByDepartment[CrewKeys.camera.rawValue] }
    public var crew: [Crew]? { crewByDepartment[CrewKeys.crew.rawValue] }
    public var lighting: [Crew]? { crewByDepartment[CrewKeys.lighting.rawValue] }
    /// A series' creators. Undocumented, but returned by every people endpoint.
    public var createdBy: [Crew]? { crewByDepartment[CrewKeys.createdBy.rawValue] }

    enum CodingKeys: String, CodingKey {
        case cast
        case guestStars = "guest_stars"
        case crew
    }

    enum CrewKeys: String, CodingKey {
        case directors = "directing"
        case writers = "writing"
        case producers = "production"
        case editors = "editing"
        case costume = "costume & make-up"
        case sound
        case art
        case visualEffects = "visual effects"
        case camera
        case crew
        case lighting
        case createdBy = "created by"
    }

    /// Any department name, so the crew object can be read without knowing its keys in advance.
    struct DepartmentKey: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            nil
        }
    }
}

extension CastAndCrew {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cast = try values.decodeIfPresent([Failable<Cast>].self, forKey: .cast)?.compactMap(\.value)
        // Absent stays nil, present-but-empty stays []: the caller can tell "not requested" from
        // "requested, none exist".
        guestStars = try values.decodeIfPresent([Failable<Cast>].self, forKey: .guestStars)?.compactMap(\.value)

        if let crewContainer = try? values.nestedContainer(keyedBy: DepartmentKey.self, forKey: .crew) {
            var departments: [String: [Crew]] = [:]
            for key in crewContainer.allKeys {
                guard let members = try? crewContainer.decode([Failable<Crew>].self, forKey: key) else { continue }
                departments[key.stringValue] = members.compactMap(\.value)
            }
            crewByDepartment = departments
        } else {
            crewByDepartment = [:]
        }
    }

    /// Lossy: this writes back only `cast` and three of the crew departments, so it does not
    /// round-trip. Nothing uploads cast and crew, so there is nothing to fix it for — but do not
    /// build anything on the assumption that encoding then decoding returns what was decoded.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cast, forKey: .cast)

        var additionalInfo = container.nestedContainer(keyedBy: CrewKeys.self, forKey: .crew)
        try additionalInfo.encodeIfPresent(directors, forKey: .directors)
        try additionalInfo.encodeIfPresent(writers, forKey: .writers)
        try additionalInfo.encodeIfPresent(producers, forKey: .producers)
    }
}
