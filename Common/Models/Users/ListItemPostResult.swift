//
//  ListItemPostResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/10/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ListItemPostResult: Codable, Hashable {
    let added: Added
    let existing: Added
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
        case added
        case existing
//        case notFound = "not_found"
    }
}
