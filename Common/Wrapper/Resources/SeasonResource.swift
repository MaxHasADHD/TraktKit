//
//  SeasonResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct SeasonResource {
    public let showId: CustomStringConvertible
    public let seasonNumber: Int
    private let path: String
    private let traktManager: TraktManager

    internal init(showId: CustomStringConvertible, seasonNumber: Int, traktManager: TraktManager) {
        self.showId = showId
        self.seasonNumber = seasonNumber
        self.path = "shows/\(showId)/seasons/\(seasonNumber)"
        self.traktManager = traktManager
    }
    
    // MARK: - Methods

    // MARK: Season

    /**
     Returns a single seasons for a show.

     ✨ Extended Info
     */
    public func info() -> Route<TraktSeason> {
        Route(path: "\(path)/info", method: .GET, traktManager: traktManager)
    }

    // MARK: Episodes

    /**
     Returns all episodes for a specific season of a show.

     **Translations**

     If you'd like to included translated episode titles and overviews in the response, include the translations parameter in the URL. Include all languages by setting the parameter to `all` or use a specific 2 digit country language code to further limit it.

     > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

     ✨ Extended Info

     - parameter translations: Include episode translations. Example: `es`
     */
    public func episodes(translations: String? = nil) -> Route<[TraktEpisode]> {
        Route(path: path,
              queryItems: ["translations": translations].compactMapValues { $0 },
              method: .GET,
              traktManager: traktManager)
    }

    /**
     Returns all translations for an season, including language and translated values for title and overview.
     */
    public func translations(language: String? = nil) -> Route<[TraktSeasonTranslation]> {
        Route(paths: [path, "translations", language], method: .GET, traktManager: traktManager)
    }

    /**
     Returns all top level comments for a season. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, most `replies`, `highest` rated, `lowest` rated, most `plays`, and highest `watched` percentage.

     > note: If you send OAuth, comments from blocked users will be automatically filtered out.

     🔓 OAuth Optional 📄 Pagination 😁 Emojis

     - parameter sort: how to sort Example: `newest`.
     - parameter authenticate: comments from blocked users will be automatically filtered out if `true`.
     */
    public func comments(sort: String? = nil, authenticate: Bool = false) -> Route<[Comment]> {
        Route(paths: [path, "comments", sort], method: .GET, requiresAuthentication: authenticate, traktManager: traktManager)
    }

    /**
     Returns all lists that contain this season. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination 😁 Emojis

     - parameter type: Filter for a specific list type. Possible values:  `all` , `personal` , `official` , `watchlists` , `favorites` .
     - parameter sort: How to sort . Possible values:  `popular` , `likes` , `comments` , `items` , `added` , `updated` .
     */
    public func containingLists(type: String? = nil, sort: String? = nil) -> Route<PagedObject<[TraktList]>> {
        Route(paths: [path, "lists", type, sort], method: .GET, traktManager: traktManager)
    }

    /**
     Returns all `cast` and `crew` for a season. Each `cast` member will have a `characters` array and a standard `person` object.The `crew` object will be broken up by department into production, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, and `editing` (if there are people for those crew positions). Each of those members will have a `jobs` array and a standard `person` object.

     **Guest Stars**

     If you add `?extended=guest_stars` to the URL, it will return all guest stars that appeared in at least 1 episode of the season.

     > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

     ✨ Extended Info
     */
    public func people() -> Route<CastAndCrew<TVCastMember, TVCrewMember>> {
        Route(paths: [path, "people"], method: .GET, traktManager: traktManager)
    }

    /**
     Returns rating (between 0 and 10) and distribution for a season.
     */
    public func ratings() -> Route<RatingDistribution> {
        Route(paths: [path, "ratings"], method: .GET, traktManager: traktManager)
    }

    /**
     Returns lots of season stats.
     */
    public func stats() -> Route<TraktStats> {
        Route(paths: [path, "stats"], method: .GET, traktManager: traktManager)
    }

    /**
     Returns all users watching this season right now.

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

    // MARK: - Resources
    
    public func episode(_ number: Int) -> EpisodeResource {
        EpisodeResource(
            showId: showId,
            seasonNumber: seasonNumber,
            episodeNumber: number,
            traktManager: traktManager
        )
    }
}
