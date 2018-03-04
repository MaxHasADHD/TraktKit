//
//  TraktCastAndCrew+Mock.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/4/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension CastAndCrew {
    static func createMock(cast: [CastMember]? = nil,
                           directors: [CrewMember]? = nil,
                           writers: [CrewMember]? = nil,
                           producers: [CrewMember]? = nil,
                           decoder: JSONDecoder) throws -> CastAndCrew {

        var jsonDictionary: [String: Any] = [:]
        jsonDictionary[CodingKeys.cast.rawValue] = try cast?.asArray()

        var crewDictionary: [String: Any] = [:]
        crewDictionary[CrewKeys.directors.rawValue] = try directors?.asArray()
        crewDictionary[CrewKeys.writers.rawValue] = try writers?.asArray()
        crewDictionary[CrewKeys.producers.rawValue] = try producers?.asArray()

        jsonDictionary[CodingKeys.crew.rawValue] = crewDictionary

        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return try decoder.decode(self, from: data)
    }
}
