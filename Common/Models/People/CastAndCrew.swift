//
//  CastAndCrew.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CastAndCrew {
    public let cast: [CastMember]?
    public let directors: [CrewMember]?
    public let writers: [CrewMember]?
    public let producers: [CrewMember]?
    
    enum CodingKeys: String, CodingKey {
        case cast
        case crew
    }
    
    enum CrewKeys: String, CodingKey {
        case directors = "directing"
        case writers = "writing"
        case producers = "production"
    }
}

extension CastAndCrew: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cast = try values.decodeIfPresent([CastMember].self, forKey: .cast)
        
        let crew = try? values.nestedContainer(keyedBy: CrewKeys.self, forKey: .crew)
        directors = try crew?.decodeIfPresent([CrewMember].self, forKey: .directors)
        writers = try crew?.decodeIfPresent([CrewMember].self, forKey: .writers)
        producers = try crew?.decodeIfPresent([CrewMember].self, forKey: .producers)
    }
}

extension CastAndCrew: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cast, forKey: .cast)
        
        var additionalInfo = container.nestedContainer(keyedBy: CrewKeys.self, forKey: .crew)
        try additionalInfo.encodeIfPresent(directors, forKey: .directors)
        try additionalInfo.encodeIfPresent(writers, forKey: .writers)
        try additionalInfo.encodeIfPresent(producers, forKey: .producers)
    }
}
