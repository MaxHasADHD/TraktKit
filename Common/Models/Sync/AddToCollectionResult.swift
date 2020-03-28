//
//  AddToCollectionResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct AddToCollectionResult: Codable, Hashable {
    let added: Added
    let updated: Added
    let existing: Added
//    let notFound: NotFound

    public struct Added: Codable, Hashable {
        let movies: Int
        let episodes: Int
    }
    
    public struct NotFound: Codable, Hashable {
        let movies: [ID]
        let shows: [ID]
        let seasons: [ID]
        let episodes: [ID]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
        case updated
        case existing
//        case notFound = "not_found"
    }
}
