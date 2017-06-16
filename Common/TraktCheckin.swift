//
//  TraktCheckin.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/29/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ShareSettings: Codable {
    public let facebook: Bool
    public let twitter: Bool
    public let tumblr: Bool
}

public struct TraktCheckin: Codable {
    
    /// Trakt History ID
    public let id: Int
    public let watchedAt: Date
    public let sharing: ShareSettings
    
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let episode: TraktEpisode?
    
    enum CodingKeys: String, CodingKey {
        case id
        case watchedAt = "watched_at"
        case sharing
        
        case movie
        case show
        case episode
    }
}
