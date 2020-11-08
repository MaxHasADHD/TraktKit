//
//  TraktScrobble.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/8/20.
//  Copyright © 2020 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktScrobble: Encodable {
    public let movie: SyncId?
    public let episode: SyncId?
    /// Progress percentage between 0 and 100.
    public let progress: Float
    /// Version number of the app.
    public let appVersion: String?
    /// Build date of the app.
    public let appDate: String?
    
    enum CodingKeys: String, CodingKey {
        case movie, episode, progress, appVersion = "app_version", appDate = "app_date"
    }
    
    public init(movie: SyncId? = nil, episode: SyncId? = nil, progress: Float, appVersion: String? = nil, appDate: String? = nil) {
        self.movie = movie
        self.episode = episode
        self.progress = progress
        self.appVersion = appVersion
        self.appDate = appDate
    }
}
