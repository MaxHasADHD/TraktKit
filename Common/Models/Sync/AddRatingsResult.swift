//
//  AddRatingsResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct AddRatingsResult: Codable {
    public let added: Added
//    public let notFound: NotFound

    public struct Added: Codable {
        public let movies: Int
        public let shows: Int
        public let seasons: Int
        public let episodes: Int
    }
    
    public struct NotFound: Codable {
        public let movies: [ID]
        public let shows: [ID]
        public let seasons: [ID]
        public let episodes: [ID]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
//        case notFound = "not_found"
    }
}
