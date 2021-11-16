//
//  AddToCollectionResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct AddToCollectionResult: Codable, Hashable {
    public let added: Added
    public let updated: Added
    public let existing: Added
    public let notFound: NotFound

    public struct Added: Codable, Hashable {
        public let movies: Int
        public let episodes: Int
    }
    
    public struct NotFound: Codable, Hashable {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
        public let episodes: [NotFoundIds]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
        case updated
        case existing
        case notFound = "not_found"
    }
}
