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
    public let directors: [Crew]?
    public let writers: [Crew]?
    public let producers: [Crew]?
    public let editors: [Crew]?
    /// Costume & make-up
    public let costume: [Crew]?
    public let sound: [Crew]?
    public let art: [Crew]?
    public let visualEffects: [Crew]?
    public let camera: [Crew]?
    public let crew: [Crew]?
    public let lighting: [Crew]?
    
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
    }
}

extension CastAndCrew {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cast = try values.decodeIfPresent([Cast].self, forKey: .cast)
        guestStars = try values.decodeIfPresent([Cast].self, forKey: .guestStars)
        
        let crewContainer = try? values.nestedContainer(keyedBy: CrewKeys.self, forKey: .crew)
        directors = try crewContainer?.decodeIfPresent([Crew].self, forKey: .directors)
        writers = try crewContainer?.decodeIfPresent([Crew].self, forKey: .writers)
        producers = try crewContainer?.decodeIfPresent([Crew].self, forKey: .producers)
        editors = try crewContainer?.decodeIfPresent([Crew].self, forKey: .editors)
        costume = try crewContainer?.decodeIfPresent([Crew].self, forKey: .costume)
        sound = try crewContainer?.decodeIfPresent([Crew].self, forKey: .sound)
        art = try crewContainer?.decodeIfPresent([Crew].self, forKey: .art)
        visualEffects = try crewContainer?.decodeIfPresent([Crew].self, forKey: .visualEffects)
        camera = try crewContainer?.decodeIfPresent([Crew].self, forKey: .camera)
        crew = try crewContainer?.decodeIfPresent([Crew].self, forKey: .crew)
        lighting = try crewContainer?.decodeIfPresent([Crew].self, forKey: .lighting)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cast, forKey: .cast)
        
        var additionalInfo = container.nestedContainer(keyedBy: CrewKeys.self, forKey: .crew)
        try additionalInfo.encodeIfPresent(directors, forKey: .directors)
        try additionalInfo.encodeIfPresent(writers, forKey: .writers)
        try additionalInfo.encodeIfPresent(producers, forKey: .producers)
    }
}
