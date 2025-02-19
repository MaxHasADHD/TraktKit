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

    init(showId: CustomStringConvertible, seasonNumber: Int) {
        self.showId = showId
        self.seasonNumber = seasonNumber
        self.path = "shows/\(showId)/seasons/\(seasonNumber)"
    }
    
    // MARK: - Methods

    /**
     Returns a single seasons for a show.

     ✨ Extended Info
     */
    public func info() -> Route<TraktSeason> {
        Route(path: "\(path)/info", method: .GET)
    }

    /**
     Returns all episodes for a specific season of a show.

     **Translations**

     If you'd like to included translated episode titles and overviews in the response, include the translations parameter in the URL. Include all languages by setting the parameter to `all` or use a specific 2 digit country language code to further limit it.

     > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

     ✨ Extended Info
     */
    public func episodes() -> Route<[TraktEpisode]> {
        Route(path: "\(path)", method: .GET)
    }

    /**
     Returns all translations for an season, including language and translated values for title and overview.
     */
    public func translations(language: String) -> Route<[TraktSeasonTranslation]> {
        Route(path: "\(path)/translations/\(language)", method: .GET)
    }

    /**
     Returns all top level comments for a season. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, most `replies`, `highest` rated, `lowest` rated, most `plays`, and highest `watched` percentage.

     > note: If you send OAuth, comments from blocked users will be automatically filtered out.

     🔓 OAuth Optional 📄 Pagination 😁 Emojis
     */
    public func comments() -> Route<[Comment]> {
        Route(path: "\(path)/comments", method: .GET)
    }
    
    // MARK: - Resources
    
    public func episode(_ number: Int) -> EpisodeResource {
        EpisodeResource(
            showId: showId,
            seasonNumber: seasonNumber,
            episodeNumber: number
        )
    }
}
