//
//  TraktPerson+Mock.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/3/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension Person {
    static func createMock(name: String,
                           ids: ID,
                           biography: String? = nil,
                           birthday: Date? = nil,
                           death: Date? = nil,
                           birthplace: String? = nil,
                           homepage: URL? = nil,
                           decoder: JSONDecoder) throws -> Person {

        var jsonDictionary: [String: Any] = [:]
        jsonDictionary[CodingKeys.name.rawValue] = name
        jsonDictionary[CodingKeys.ids.rawValue] = try ids.asDictionary()

        jsonDictionary[CodingKeys.biography.rawValue] = biography
        jsonDictionary[CodingKeys.birthday.rawValue] = birthday
        jsonDictionary[CodingKeys.death.rawValue] = death
        jsonDictionary[CodingKeys.birthplace.rawValue] = birthplace
        jsonDictionary[CodingKeys.homepage.rawValue] = homepage

        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return try decoder.decode(self, from: data)
    }
}
