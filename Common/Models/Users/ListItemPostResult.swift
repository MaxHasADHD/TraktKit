//
//  ListItemPostResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/10/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ListItemPostResult: Codable {
    let added: Added
    let existing: Added
    let notFound: NotFound

    public struct Added: Codable {
        let movies: Int
        let shows: Int
        let seasons: Int
        let episodes: Int
        let people: Int
    }

    public struct NotFoundItem: Codable {
        let ids: ID
    }

    public struct NotFound: Codable {
        let movies: [NotFoundItem]
        let shows: [NotFoundItem]
        let seasons: [NotFoundItem]
        let episodes: [NotFoundItem]
    }

    enum CodingKeys: String, CodingKey {
        case added
        case existing
        case notFound = "not_found"
    }
}
