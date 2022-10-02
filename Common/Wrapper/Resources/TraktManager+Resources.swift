//
//  TraktManager+Resources.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {

    public func show(id: CustomStringConvertible) -> ShowResource {
        ShowResource(id: id, traktManager: self)
    }

    public func season(showId: CustomStringConvertible, season: Int) -> SeasonResource {
        SeasonResource(showId: showId, seasonNumber: season, traktManager: self)
    }
    
    public func episode(showId: CustomStringConvertible, season: Int, episode: Int) -> EpisodeResource {
        EpisodeResource(showId: showId, seasonNumber: season, episodeNumber: episode, traktManager: self)
    }
    
    public func currentUser() -> CurrentUserResource {
        CurrentUserResource()
    }
    
    public func user(_ username: String) -> UsersResource {
        UsersResource(username: username, traktManager: self)
    }
    
    public func search() -> SearchResource {
        SearchResource(traktManager: self)
    }
}
