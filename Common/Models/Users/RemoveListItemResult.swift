//
//  RemoveListItemResult.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 8/11/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveListItemResult: Codable, Hashable {
    let deleted: Added
//    let notFound: NotFound

    public struct Added: Codable, Hashable {
        let movies: Int
        let shows: Int
        let seasons: Int
        let episodes: Int
        let people: Int
    }
    
    public struct NotFound: Codable, Hashable {
        let movies: [ID]
        let shows: [ID]
        let seasons: [ID]
        let episodes: [ID]
        let people: [ID]
    }
    
    enum CodingKeys: String, CodingKey {
        case deleted
//        case notFound = "not_found"
    }
}
