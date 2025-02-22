//
//  TraktManager+Resources.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {

    // MARK: - Search

    public func search() -> SearchResource {
        SearchResource(traktManager: self)
    }

    // MARK: - Movies

    public var movies: MoviesResource {
        MoviesResource(traktManager: self)
    }

    /// - parameter id: Trakt ID, Trakt slug, or IMDB ID
    public func movie(id: CustomStringConvertible) -> MovieResource {
        MovieResource(id: id, traktManager: self)
    }

    // MARK: - TV

    public var shows: ShowsResource {
        ShowsResource(traktManager: self)
    }

    /// - parameter id: Trakt ID, Trakt slug, or IMDB ID
    public func show(id: CustomStringConvertible) -> ShowResource {
        ShowResource(id: id, traktManager: self)
    }

    public func season(showId: CustomStringConvertible, season: Int) -> SeasonResource {
        SeasonResource(showId: showId, seasonNumber: season, traktManager: self)
    }
    
    public func episode(showId: CustomStringConvertible, season: Int, episode: Int) -> EpisodeResource {
        EpisodeResource(showId: showId, seasonNumber: season, episodeNumber: episode, traktManager: self)
    }

    // MARK: - User

    public func currentUser() -> CurrentUserResource {
        CurrentUserResource(traktManager: self)
    }
    
    public func user(_ username: String) -> UsersResource {
        UsersResource(username: username, traktManager: self)
    }
}
