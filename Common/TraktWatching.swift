//
//  TraktWatching.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/1/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatching: TraktProtocol {
    public let expiresAt: Date
    public let startedAt: Date
    public let action: String
    public let type: String
    
    public let episode: TraktEpisode?
    public let show: TraktShow?
    public let movie: TraktMovie?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let expiresAt = Date.dateFromString(json["expires_at"]),
            let startedAt = Date.dateFromString(json["started_at"]),
            let action = json["action"] as? String,
            let type = json["type"] as? String else { return nil }
        
        self.expiresAt = expiresAt
        self.startedAt = startedAt
        self.action = action
        self.type = type
        
        self.episode = TraktEpisode(json: json["episode"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
    }
}
