//
//  EpisodeResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct EpisodeResource {
    public let showId: CustomStringConvertible
    public let seasonNumber: Int
    public let episodeNumber: Int
    private let path: String
    private let traktManager: TraktManager

    internal init(showId: CustomStringConvertible, seasonNumber: Int, episodeNumber: Int, traktManager: TraktManager) {
        self.showId = showId
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.path = "shows/\(showId)/seasons/\(seasonNumber)/episodes/\(episodeNumber)"
        self.traktManager = traktManager
    }

    /**
     Returns a single episode's details. All date and times are in UTC and were calculated using the episode's `air_date` and show's `country` and `air_time`.

     > note:  If the `first_aired` is unknown, it will be set to `null`.

     > note: When getting `full` extended info, the `episode_type` field can have a value of `standard`, `series_premiere` (season 1, episode 1), `season_premiere` (episode 1), `mid_season_finale`, `mid_season_premiere` (the next episode after the mid season finale), `season_finale`, or `series_finale` (last episode to air for an ended show).
     */
    public func summary() -> Route<TraktEpisode> {
        Route(path: path, method: .GET, traktManager: traktManager)
    }

    /**
     Returns all translations for an episode, including language and translated values for title and overview.

     - parameter language: 2 character language code
     */
    public func translations(language: String? = nil) -> Route<[TraktEpisodeTranslation]> {
        Route(paths: [path, "translations", language], method: .GET, traktManager: traktManager)
    }

    /**
     Returns all top level comments for an episode. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, most `replies`, `highest` rated, `lowest` rated, and most `plays`.

     > note: If you send OAuth, comments from blocked users will be automatically filtered out.

     🔓 OAuth Optional 📄 Pagination 😁 Emojis

     - parameter sort: how to sort Example: `newest`.
     - parameter authenticate: comments from blocked users will be automatically filtered out if `true`.
     */
    public func comments(sort: String? = nil, authenticate: Bool = false) -> Route<[Comment]> {
        Route(paths: [path, "comments", sort], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
    }

    /**
     Returns all lists that contain this episode. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    public func containingLists() -> Route<[TraktList]> {
        Route(path: path + "/lists", method: .GET, traktManager: traktManager)
    }

    /**
     Returns all lists that contain this episode. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination 😁 Emojis

     - parameter type: Filter for a specific list type. Possible values:  `all` , `personal` , `official` , `watchlists` , `favorites` .
     - parameter sort: How to sort . Possible values:  `popular` , `likes` , `comments` , `items` , `added` , `updated` .
     */
    public func containingLists(type: String? = nil, sort: String? = nil) -> Route<PagedObject<[TraktList]>> {
        Route(paths: [path, "lists", type, sort], method: .GET, traktManager: traktManager)
    }

    /**
     Returns all `cast` and `crew` for an episode. Each `cast` member will have a `characters` array and a standard person object.

     The `crew` object will be broken up by department into `production, art, crew, costume & make-up, directing, writing, sound, camera, visual effects, lighting, and editing` (if there are people for those crew positions). Each of those members will have a `jobs` array and a standard `person` object.

     **Guest Stars**

     If you add `?extended=guest_stars` to the URL, it will return all guest stars that appeared in the episode.

     > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

     ✨ Extended Info
     */
    public func people() -> Route<CastAndCrew<TVCastMember, TVCrewMember>> {
        Route(paths: [path, "people"], method: .GET, traktManager: traktManager)
    }

    /**
     Returns rating (between 0 and 10) and distribution for an episode.
     */
    public func ratings() -> Route<RatingDistribution> {
        Route(paths: [path, "ratings"], method: .GET, traktManager: traktManager)
    }

    /**
     Returns lots of episode stats.
     */
    public func stats() -> Route<TraktStats> {
        Route(paths: [path, "stats"], method: .GET, traktManager: traktManager)
    }

    /**
     Returns all users watching this episode right now.

     ✨ Extended Info
     */
    public func usersWatching() -> Route<[User]> {
        Route(paths: [path, "watching"], method: .GET, traktManager: traktManager)
    }

    /**
     Returns all videos including trailers, teasers, clips, and featurettes.

     ✨ Extended Info
     */
    public func videos() -> Route<[TraktVideo]> {
        Route(paths: [path, "videos"], method: .GET, traktManager: traktManager)
    }
}

extension Route where T == [TraktList] {
    func listType(_ listType: ListType) -> Self {
        var copy = self
        copy.path = "\(path)/\(listType.rawValue)"
        return copy
    }

    func sort(by sortType: ListSortType) -> Self {
        var copy = self
        copy.path = "\(path)/\(sortType.rawValue)"
        return copy
    }
}
