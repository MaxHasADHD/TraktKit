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
    
    init(showId: CustomStringConvertible, seasonNumber: Int, episodeNumber: Int) {
        self.showId = showId
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.path = "shows/\(showId)/seasons/\(seasonNumber)/episodes/\(episodeNumber)"
    }

    /**
     Returns a single episode's details. All date and times are in UTC and were calculated using the episode's `air_date` and show's `country` and `air_time`.

     **Note**: If the `first_aired` is unknown, it will be set to `null`.
     */
    public func summary() -> Route<TraktEpisode> {
        Route(path: path, method: .GET)
    }

    /**
     Returns all translations for an episode, including language and translated values for title and overview.

     - parameter language: 2 character language code
     */
    public func translations(language: String? = nil) -> Route<[TraktEpisodeTranslation]> {
        var path = path + "/translations"
        if let language {
            path += "/\(language)"
        }
        return Route(path: path, method: .GET)
    }

    /**
     Returns all top level comments for an episode. Most recent comments returned first.

     📄 Pagination
     */
    public func comments() -> Route<[Comment]> {
        Route(path: path + "/comments", method: .GET)
    }

    /**
     Returns all lists that contain this episode. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    public func containingLists() -> Route<[TraktList]> {
        Route(path: path + "/lists", method: .GET)
    }

    /**
     Returns rating (between 0 and 10) and distribution for an episode.
     */
    public func ratings() -> Route<RatingDistribution> {
        Route(path: path + "/ratings", method: .GET)
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
        Route(path: path + "/comments", method: .GET)
    }

    /**
     Returns lots of episode stats.
     */
    public func stats() -> Route<TraktStats> {
        Route(path: path + "/stats", method: .GET)
    }

    /**
     Returns all users watching this episode right now.
     ✨ Extended Info
     */
    public func usersWatching() -> Route<[User]> {
        Route(path: path + "/watching", method: .GET)
    }

    /**
     Returns all videos including trailers, teasers, clips, and featurettes.
     ✨ Extended Info
     */
    public func videos() -> Route<[TraktVideo]> {
        Route(path: path + "/videos", method: .GET)
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
