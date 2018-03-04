//
//  TraktShow+Mock.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/27/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktShow {
    static func createMock(title: String, year: Int?, ids: ID, decoder: JSONDecoder) throws -> TraktShow {

        var jsonDictionary: [String: Any] = [:]
        jsonDictionary[CodingKeys.title.rawValue] = title
        jsonDictionary[CodingKeys.year.rawValue] = year
        jsonDictionary[CodingKeys.ids.rawValue] = try ids.asDictionary()

        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return try decoder.decode(self, from: data)
    }
}
