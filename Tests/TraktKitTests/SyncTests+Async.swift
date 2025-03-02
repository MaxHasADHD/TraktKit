//
//  SyncTests+Async.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/1/25.
//

import Foundation
import Testing

extension TraktTestSuite {
    @Suite(.serialized)
    struct SyncTestSuite {
        @Test func getLastActivities() async throws {
            try mock(.GET, "https://api.trakt.tv/sync/last_activities", result: .success(jsonData(named: "test_get_last_activity")))

            let lastActivities = try await traktManager.sync()
                .lastActivities()
                .perform()

            // Date formatter to convert date back into String
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = .gmt
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

            #expect(dateFormatter.string(from: lastActivities.all) == "2014-11-20T07:01:32.000Z")

            #expect(dateFormatter.string(from: lastActivities.movies.watchedAt) == "2014-11-19T21:42:41.000Z")
            #expect(dateFormatter.string(from: lastActivities.movies.collectedAt) == "2014-11-20T06:51:30.000Z")
            #expect(dateFormatter.string(from: lastActivities.movies.ratedAt) == "2014-11-19T18:32:29.000Z")
            #expect(dateFormatter.string(from: lastActivities.movies.watchlistedAt) == "2014-11-19T21:42:41.000Z")
            #expect(dateFormatter.string(from: lastActivities.movies.favoritesAt) == "2014-11-19T21:42:41.000Z")
            #expect(dateFormatter.string(from: lastActivities.movies.commentedAt) == "2014-11-20T06:51:30.000Z")
            #expect(dateFormatter.string(from: lastActivities.movies.pausedAt) == "2014-11-20T06:51:30.000Z")
            #expect(dateFormatter.string(from: lastActivities.movies.hiddenAt) == "2016-08-20T06:51:30.000Z")

            #expect(dateFormatter.string(from: lastActivities.episodes.watchedAt) == "2014-11-20T06:51:30.000Z")
            #expect(dateFormatter.string(from: lastActivities.episodes.collectedAt) == "2014-11-19T22:02:41.000Z")
            #expect(dateFormatter.string(from: lastActivities.episodes.ratedAt) == "2014-11-20T06:51:30.000Z")
            #expect(dateFormatter.string(from: lastActivities.episodes.watchlistedAt) == "2014-11-20T06:51:30.000Z")
            #expect(dateFormatter.string(from: lastActivities.episodes.commentedAt) == "2014-11-20T06:51:30.000Z")
            #expect(dateFormatter.string(from: lastActivities.episodes.pausedAt) == "2014-11-20T06:51:30.000Z")
        }

        // MARK: - Watchlist

        @Test func getWatchlist() async throws {
            try mock(.GET, "https://api.trakt.tv/sync/watchlist/movies?extended=min", result: .success(jsonData(named: "test_get_watchlist")))

            let watchlist = try await traktManager.sync()
                .watchlist(type: "movies")
                .extend(.Min)
                .perform()
                .object

            #expect(watchlist.count == 2)

            let firstItem = try #require(watchlist.first)
            #expect(firstItem.rank == 1)
            #expect(firstItem.id == 101)
            #expect(firstItem.type == "movie")
            #expect(firstItem.movie?.title == "TRON: Legacy")
            #expect(firstItem.notes == "Need to catch up before TRON 3 is out.")
        }

        @Test func addToWatchlist() async throws {
            try mock(.POST, "https://api.trakt.tv/sync/watchlist", result: .success(jsonData(named: "test_add_items_to_watchlist")))

            let result = try await traktManager.sync()
                .addToWatchlist()
                .perform()

            #expect(result.added.movies == 1)
            #expect(result.added.shows == 1)
            #expect(result.added.seasons == 1)
            #expect(result.added.episodes == 2)

            #expect(result.notFound.movies.count == 1)

            #expect(result.list.itemCount == 5)
        }
    }
}
