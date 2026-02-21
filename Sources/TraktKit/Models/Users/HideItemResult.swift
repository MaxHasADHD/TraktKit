//
//  HideItemResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 9/8/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct HideItemResult: TraktObject {
    public let added: Added
    public let notFound: NotFound

    public struct Added: TraktObject {
        public let movies: Int
        public let shows: Int
        public let seasons: Int
        public let users: Int
    }
    
    public struct NotFound: TraktObject {
        public let movies: [NotFoundIds]
        public let shows: [NotFoundIds]
        public let seasons: [NotFoundIds]
        public let users: [NotFoundIds]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
        case notFound = "not_found"
    }
}
