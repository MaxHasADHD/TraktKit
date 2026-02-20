//
//  TraktManager+Resources.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {

    // MARK: - Authentication

    public func auth() -> AuthenticationResource {
        AuthenticationResource(traktManager: self)
    }

    // MARK: - Checkin

    public func checkin() -> CheckinResource {
        CheckinResource(traktManager: self)
    }

    // MARK: - Comments

    public var comments: CommentsResource {
        CommentsResource(traktManager: self)
    }

    /// - parameter id: Trakt comment ID
    public func comment(id: CustomStringConvertible) -> CommentResource {
        CommentResource(id: id, traktManager: self)
    }

    // MARK: - Countries

    public var countries: CountriesResource {
        CountriesResource(traktManager: self)
    }

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

    // MARK: - Calendars

    /// Endpoints for the authenticated user's personal calendar.
    public var myCalendar: MyCalendarResource {
        MyCalendarResource(traktManager: self)
    }

    /// Endpoints for the global calendar (no authentication required).
    public var allCalendar: AllCalendarResource {
        AllCalendarResource(traktManager: self)
    }

    // MARK: - Genres

    public var genres: GenresResource {
        GenresResource(traktManager: self)
    }

    // MARK: - Languages

    public var languages: LanguagesResource {
        LanguagesResource(traktManager: self)
    }

    // MARK: - Networks

    public var networks: NetworksResource {
        NetworksResource(traktManager: self)
    }

    // MARK: - Notes

    public var notes: NotesResource {
        NotesResource(traktManager: self)
    }

    /// - parameter id: Trakt note ID
    public func note(id: CustomStringConvertible) -> NoteResource {
        NoteResource(id: id, traktManager: self)
    }

    // MARK: - Lists

    public var lists: ListsResource {
        ListsResource(traktManager: self)
    }

    /// - parameter id: Trakt ID or Trakt slug
    public func list(id: CustomStringConvertible) -> ListResource {
        ListResource(id: id, traktManager: self)
    }

    // MARK: - People

    public var people: PeopleResource {
        PeopleResource(traktManager: self)
    }

    /// - parameter id: Trakt ID, Trakt slug, or IMDB ID
    public func person(id: CustomStringConvertible) -> PersonResource {
        PersonResource(id: id, traktManager: self)
    }

    public func sync() -> SyncResource {
        SyncResource(traktManager: self)
    }

    // MARK: - User

    public func currentUser() -> CurrentUserResource {
        CurrentUserResource(traktManager: self)
    }
    
    public func user(_ slug: String) -> UsersResource {
        UsersResource(slug: slug, traktManager: self)
    }
}
