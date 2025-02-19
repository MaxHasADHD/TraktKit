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
     Returns all shows updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.

     📄 Pagination

     > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

     > note: .The `startDate` can only be a maximum of 30 days in the past.
     */
    public static func recentlyUpdated(since startDate: Date) async throws -> Route<[Update]> {
        let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
        return Route(path: "shows/updates/\(formattedDate)", method: .GET)
    }

    /**
     Returns all show Trakt IDs updated since the specified UTC date and time. We recommended storing the X-Start-Date header you can be efficient using this method moving forward. By default, 10 results are returned. You can send a limit to get up to 100 results per page.

     📄 Pagination

     > important: The `startDate` is only accurate to the hour, for caching purposes. Please drop the minutes and seconds from your timestamp to help optimize our cached data. For example, use `2021-07-17T12:00:00Z` and not `2021-07-17T12:23:34Z`

     > note: .The `startDate` can only be a maximum of 30 days in the past.
     */
    public static func recentlyUpdatedIds(since startDate: Date) async throws -> Route<[Update]> {
        let formattedDate = startDate.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
        return Route(path: "shows/updates/id\(formattedDate)", method: .GET)
    }

    // MARK: - Properties

    public let id: CustomStringConvertible

    // MARK: - Lifecycle

    public init(id: CustomStringConvertible) {
        self.id = id
    }

    // MARK: - Methods

    public func summary() -> Route<TraktShow> {
        Route(path: "shows/\(id)", method: .GET)
    }

    public func aliases() -> Route<[Alias]> {
        Route(path: "shows/\(id)/aliases", method: .GET)
    }

    public func certifications() -> Route<Certifications> {
        Route(path: "shows/\(id)/certifications", method: .GET)
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
