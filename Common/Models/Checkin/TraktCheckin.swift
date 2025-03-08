//
//  TraktCheckin.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/29/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/**
 The sharing object is optional and will apply the user's settings if not sent. If sharing is sent, each key will override the user's setting for that social network. Send true to post or false to not post on the indicated social network. You can see which social networks a user has connected with the /users/settings method.
 */
public struct ShareSettings: TraktObject {
    public let facebook: Bool
    public let twitter: Bool
    public let mastodon: Bool
    public let tumblr: Bool
}

public struct TraktCheckinBody: TraktObject {
    /// `movie` or `episode` must not be nil
    public let movie: SyncId?
    /// `movie` or `episode` must not be nil
    public let episode: SyncId?
    /// Control sharing to any connected social networks.
    public let sharing: ShareSettings?
    /// Message used for sharing. If not sent, it will use the watching string in the user settings.
    public let message: String?

    /**
     - parameters:
        - sharing: The sharing object is optional and will apply the user's settings if not sent. If `sharing` is sent, each key will override the user's setting for that social network. Send `true` to post or `false` to not post on the indicated social network. You can see which social networks a user has connected with the `/users/settings` method.
        - message: Message used for sharing. If not sent, it will use the watching string in the user settings.
     */
    public init(movie: SyncId? = nil, episode: SyncId? = nil, sharing: ShareSettings? = nil, message: String? = nil) {
        self.movie = movie
        self.episode = episode
        self.sharing = sharing
        self.message = message
    }
}

public struct TraktCheckinResponse: TraktObject {
    
    /// A unique history id (64-bit integer) used to reference this checkin directly.
    public let id: Int
    public let watchedAt: Date
    public let sharing: ShareSettings

    /// If the user checked in to a movie, a movie object will be returned with it's name
    public let movie: TraktMovie?
    /// If the user checked in to an episode, a show object will be returned with it's name
    public let show: TraktShow?
    /// If the user checked in to an episode, an episode object will be returned with it's name, season + episode number.
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
