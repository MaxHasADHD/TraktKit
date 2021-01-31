//
//  HideItemResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 9/8/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct HideItemResult: Codable, Hashable {
    public let added: Added
    public let notFound: NotFound

    public struct Added: Codable, Hashable {
        public let movies: Int
        public let shows: Int
        public let seasons: Int
    }
    
    public struct NotFound: Codable, Hashable {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
        case notFound = "not_found"
    }
}
