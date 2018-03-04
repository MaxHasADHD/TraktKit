//
//  TraktCastMember+Mock.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/4/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension CastMember {
    static func createMock(character: String,
                           person: Person? = nil,
                           movie: TraktMovie? = nil,
                           show: TraktShow? = nil,
                           decoder: JSONDecoder) throws -> CastMember {

        var jsonDictionary: [String: Any] = [:]
        jsonDictionary["character"] = character
        jsonDictionary["person"] = try person?.asDictionary()
        jsonDictionary["movie"] = try movie?.asDictionary()
        jsonDictionary["show"] = try show?.asDictionary()

        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return try decoder.decode(self, from: data)
    }
}
