//
//  ShowResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ShowResource {

    // MARK: - Static (Non-specific show endpoints)

    /**
     Returns all shows being watched right now. Shows with the most users are returned first.
     */
    public static func trending() -> Route<PagedObject<[TraktTrendingShow]>> {
        Route(path: "shows/trending", method: .GET)
    }

    /**
     Returns the most popular shows. Popularity is calculated using the rating percentage and the number of ratings.
     */
    public static func popular() -> Route<PagedObject<[TraktShow]>> {
        Route(path: "shows/trending", method: .GET)
    }

    /**
     Returns the most favorited shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     */
    public static func favorited(period: Period? = nil) -> Route<PagedObject<[TraktFavoritedShow]>> {
        Route(paths: ["shows/favorited", period], method: .GET)
    }

    /**
     Returns the most played (a single user can watch multiple episodes multiple times) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     */
    public static func played(period: Period? = nil) -> Route<PagedObject<[TraktMostShow]>> {
        Route(paths: ["shows/played", period], method: .GET)
    }

    /**
     Returns the most watched (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     */
    public static func watched(period: Period? = nil) -> Route<PagedObject<[TraktMostShow]>> {
        Route(paths: ["shows/watched", period], method: .GET)
    }

    /**
     Returns the most collected (unique users) shows in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
     */
    public static func collected(period: Period? = nil) -> Route<PagedObject<[TraktMostShow]>> {
        Route(paths: ["shows/collected", period], method: .GET)
    }

    /**
     Returns the most anticipated shows based on the number of lists a show appears on.
     */
    public static func anticipated() -> Route<PagedObject<[TraktAnticipatedShow]>> {
        Route(path: "shows/anticipated", method: .GET)
    }

    /**
     Returns all shows updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.

     📄 Pagination

     > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

     > note: .The `startDate` can only be a maximum of 30 days in the past.
     */
    public static func recentlyUpdated(since startDate: Date) async throws -> Route<PagedObject<[Update]>> {
        let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
        return Route(path: "shows/updates/\(formattedDate)", method: .GET)
    }

    /**
     Returns all show Trakt IDs updated since the specified UTC date and time. We recommended storing the X-Start-Date header you can be efficient using this method moving forward. By default, 10 results are returned. You can send a limit to get up to 100 results per page.

     📄 Pagination

     > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

     > note: .The `startDate` can only be a maximum of 30 days in the past.
     */
    public static func recentlyUpdatedIds(since startDate: Date) async throws -> Route<PagedObject<[Int]>> {
        let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
        return Route(path: "shows/updates/id\(formattedDate)", method: .GET)
    }

    // MARK: - Properties

    /// Trakt ID, Trakt slug, or IMDB ID
    public let id: CustomStringConvertible

    // MARK: - Lifecycle

    public init(id: CustomStringConvertible) {
        self.id = id
    }

    // MARK: - Methods

    /**
     Returns a single shows's details. If you request extended info, the `airs` object is relative to the show's country. You can use the `day`, `time`, and `timezone` to construct your own date then convert it to whatever timezone your user is in.
     */
    public func summary() -> Route<TraktShow> {
        Route(path: "shows/\(id)", method: .GET)
    }

    /**
     Returns all title aliases for a show. Includes country where name is different.
     */
    public func aliases() -> Route<[Alias]> {
        Route(path: "shows/\(id)/aliases", method: .GET)
    }

    /**
     Returns all content certifications for a show, including the country.
     */
    public func certifications() -> Route<Certifications> {
        Route(path: "shows/\(id)/certifications", method: .GET)
    }

    /**
     Returns all translations for a show, including language and translated values for title and overview.

     - parameter language: 2 character language code Example: `es`
     */
    public func translations(language: String? = nil) -> Route<[TraktShowTranslation]> {
        Route(paths: ["shows/\(id)/translations", language], method: .GET)
    }

    /**
     Returns all top level comments for a show. By default, the `newest` comments are returned first. Other sorting options include `oldest`, most `likes`, most `replies`, `highest` rated, `lowest` rated, most `plays`, and highest `watched` percentage.

     🔓 OAuth Optional 📄 Pagination 😁 Emojis

     > note: If you send OAuth, comments from blocked users will be automatically filtered out.

     - parameter sort: how to sort Example: `newest`.
     - parameter authenticate: comments from blocked users will be automatically filtered out if `true`.
     */
    public func comments(sort: String? = nil, authenticate: Bool = false) -> Route<PagedObject<[Comment]>> {
        Route(paths: ["shows/\(id)/comments", sort], method: .GET, requiresAuthentication: authenticate)
    }

    /**
     Returns all seasons for a show including the number of episodes in each season.

     **Episodes**

     If you add `?extended=episodes` to the URL, it will return all episodes for all seasons.

     > note: This returns a lot of data, so please only use this extended parameter if you actually need it!

     ✨ Extended Info
     */
    public func seasons() -> Route<[TraktSeason]> {
        Route(path: "shows/\(id)/seasons", method: .GET)
    }

    // MARK: - Resources

    public func season(_ number: Int) -> SeasonResource {
        SeasonResource(showId: id, seasonNumber: number)
    }
}
