//
//  TraktWatching.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/1/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatching: Codable {
    public let expiresAt: Date
    public let startedAt: Date
    public let action: String
    public let type: String
    
    public let episode: TraktEpisode?
    public let show: TraktShow?
    public let movie: TraktMovie?
    
    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case startedAt = "started_at"
        case action
        case type
        
        case episode
        case show
        case movie
    }
}
