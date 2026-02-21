//
//  TraktMovieRelease.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktMovieRelease: TraktObject {
    public let country: String
    public let certification: String
    public let releaseDate: Date
    public let releaseType: ReleaseType
    /// The `note` might have optional info such as the film festival name for a premiere release or Blu-ray specs for a `physical` release.
    public let note: String?
    
    enum CodingKeys: String, CodingKey {
        case country
        case certification
        case releaseDate = "release_date"
        case releaseType = "release_type"
        case note
    }
    
    public enum ReleaseType: String, TraktObject {
        case unknown
        case premiere
        case limited
        case theatrical
        case digital
        case physical
        case tv
    }
}
