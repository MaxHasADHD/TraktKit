//
//  AddRatingsResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct AddRatingsResult: Codable {
    let added: Added
    let notFound: NotFound
    
    public struct Added: Codable {
        let movies: Int
        let shows: Int
        let seasons: Int
        let episodes: Int
    }
    
    public struct NotFound: Codable {
        let movies: [ID]
        let shows: [ID]
        let seasons: [ID]
        let episodes: [ID]
    }
    
    enum CodingKeys: String, CodingKey {
        case added
        case notFound = "not_found"
    }
}
