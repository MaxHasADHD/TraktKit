//
//  TraktMovieRelease.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktMovieRelease: Codable {
    let country: String
    let certification: String
    let releaseDate: Date
    let releaseType: ReleaseType
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case country
        case certification
        case releaseDate = "release_date"
        case releaseType = "release_type"
        case note
    }
    
    public enum ReleaseType: String, Codable {
        case unknown
        case premiere
        case limited
        case theatrical
        case digital
        case physical
        case tv
    }
}
