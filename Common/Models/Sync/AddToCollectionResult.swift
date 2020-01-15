//
//  AddToCollectionResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct AddToCollectionResult: Codable {
    let added: Added
    let updated: Added
    let existing: Added
    let notFound: NotFound

    public struct Added: Codable {
        let movies: Int
        let episodes: Int
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
        case updated
        case existing
        case notFound = "not_found"
    }
}
