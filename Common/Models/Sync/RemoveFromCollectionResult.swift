//
//  RemoveFromCollectionResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RemoveFromCollectionResult: Codable, Hashable {
    public let deleted: deleted
//    public let notFound: NotFound

    public struct deleted: Codable, Hashable {
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
        case deleted
//        case notFound = "not_found"
    }
}
