//
//  UnhideItemResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 9/4/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct UnhideItemResult: TraktObject {
    public let deleted: Deleted
    public let notFound: NotFound

    public struct Deleted: TraktObject {
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
        case deleted
        case notFound = "not_found"
    }
}
