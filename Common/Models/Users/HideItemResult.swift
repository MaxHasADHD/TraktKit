//
//  HideItemResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 9/8/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct HideItemResult: Codable {
    
    let added: Added
//    let notFound: NotFound

    public struct Added: Codable {
        let movies: Int
        let shows: Int
        let seasons: Int
    }
    
    public struct NotFound: Codable {
        let movies: [ID]
        let shows: [ID]
        let seasons: [ID]
        
        enum CodingKeys: String, CodingKey {
            case movies
            case shows
            case seasons
        }
        
        public init(from decoder: Decoder) throws {
            movies = []
            shows = []
            seasons = []
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case added
//        case notFound = "not_found"
    }
}
