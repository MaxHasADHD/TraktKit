//
//  SyncTests+Async.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/1/25.
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct SyncTestSuite {
        @Test func getLastActivities() async throws {
            let traktManager = await authenticatedTraktManager()
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

        // MARK: - Playback

        @Test func getMoviePlaybackProgress() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/playback/movies", result: .success(jsonData(named: "test_get_playback_progress")))

            let progress = try await traktManager.sync()
                .playback(type: "movies")
                .perform()

            #expect(progress.count == 2)
            let firstItem = try #require(progress.first)
            #expect(firstItem.id == 13)
        }

        @Test func removePlaybackProgress() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.DELETE, "https://api.trakt.tv/sync/playback/13", result: .success(.init()), httpCode: StatusCodes.SuccessNoContentToReturn)

            try await traktManager.sync().removePlayback(id: 13).perform()
        }

        // MARK: - Collection

        @Test func getCollectedMovies() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/collection/movies?extended=min", result: .success(jsonData(named: "test_get_collection")))

            let movies = try await traktManager.sync()
                .collection(type: "movies")
                .extend(.Min)
                .perform()
            #expect(movies.count == 2)
        }

        @Test func getCollectedShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/collection/shows?extended=min", result: .success(jsonData(named: "test_get_collection_shows")))

            let movies = try await traktManager.sync()
                .collection(type: "shows")
                .extend(.Min)
                .perform()
            #expect(movies.count == 2)
        }

        @Test func addItemsToCollection() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.POST, "https://api.trakt.tv/sync/collection", result: .success(jsonData(named: "test_add_items_to_collection")))

            let result = try await traktManager.sync()
                .addToCollection(movies: []) // For mock we don't have to pass anything in.
                .perform()
            #expect(result.added.movies == 1)
            #expect(result.added.episodes == 12)
        }

        @Test func removeItemsFromCollection() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/collection/remove", result: .success(jsonData(named: "test_remove_items_from_collection")))

            let result = try await traktManager.sync()
                .removeFromCollection(movies: []) // For mock we don't have to pass anything in.
                .perform()

            #expect(result.deleted.movies == 1)
            #expect(result.deleted.episodes == 12)
            #expect(result.notFound.episodes.count == 0)
            #expect(result.notFound.movies.count == 1)
        }

        // MARK: - Watched

        @Test func getWatchedMovies() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/watched/movies?extended=min", result: .success(jsonData(named: "test_get_watched")))

            let watchedMovies = try await traktManager.sync()
                .watchedMovies()
                .extend(.Min)
                .perform()
            #expect(watchedMovies.count == 2)
        }

        @Test func getWatchedShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/watched/shows?extended=min", result: .success(jsonData(named: "test_get_watched_shows")))

            let watchedShows = try await traktManager.sync()
                .watchedShows()
                .extend(.Min)
                .perform()
            #expect(watchedShows.count == 2)
            #expect(watchedShows.allSatisfy { $0.seasons != nil })
        }

        @Test func getWatchedShowsWithoutSeasons() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/watched/shows?extended=noseasons", result: .success(jsonData(named: "test_get_watched_shows_noseasons")))

            let watchedShows = try await traktManager.sync()
                .watchedShows()
                .extend(.noSeasons)
                .perform()
            #expect(watchedShows.count == 2)
            #expect(watchedShows.allSatisfy { $0.seasons == nil })
        }

        // MARK: - History

        @Test func getHistory() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/history/movies?extended=min", result: .success(jsonData(named: "test_get_watched_history")))

            let history = try await traktManager.sync()
                .history(type: "movies")
                .extend(.Min)
                .perform()
                .object

            #expect(history.count == 3)
        }

        @Test func addItemsToHistory() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.POST, "https://api.trakt.tv/sync/history", result: .success(jsonData(named: "test_add_items_to_watched_history")))

            let result = try await traktManager.sync()
                .addToHistory()
                .perform()

            #expect(result.added.movies == 2)
            #expect(result.added.episodes == 72)
        }

        @Test func removeItemsFromHistory() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/history/remove", result: .success(jsonData(named: "test_remove_items_from_history")))

            let result = try await traktManager.sync()
                .removeFromHistory()
                .perform()

            #expect(result.deleted.movies == 2)
            #expect(result.deleted.episodes == 72)
        }

        // MARK: - Ratings

        @Test func getRatings() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/ratings/movies/9", result: .success(jsonData(named: "test_get_ratings")))

            let ratings = try await traktManager.sync()
                .ratings(type: "movies", rating: 9)
                .perform()
                .object

            #expect(ratings.count == 2)
        }

        @Test func addRating() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.POST, "https://api.trakt.tv/sync/ratings", result: .success(jsonData(named: "test_add_new_ratings")))

            let result = try await traktManager.sync()
                .addRatings()
                .perform()

            #expect(result.added.movies == 1)
            #expect(result.added.shows == 1)
            #expect(result.added.seasons == 1)
            #expect(result.added.episodes == 2)
            #expect(result.notFound.movies.count == 1)
        }

        @Test func removeRating() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/sync/ratings/remove", result: .success(jsonData(named: "test_remove_ratings")))

            let result = try await traktManager.sync()
                .removeRatings()
                .perform()

            #expect(result.deleted.movies == 1)
            #expect(result.deleted.shows == 1)
            #expect(result.deleted.seasons == 1)
            #expect(result.deleted.episodes == 2)
        }

        // MARK: - Watchlist

        @Test func getWatchlist() async throws {
            let traktManager = await authenticatedTraktManager()
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
            let traktManager = await authenticatedTraktManager()
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
