//
//  SeasonTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/28/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Season Tests")
    struct SeasonTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        // MARK: - Summary

        @Test func getAllSeasons() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons?extended=min", result: .success(jsonData(named: "test_get_all_seasons")))

            let seasons = try await traktManager
                .show(id: "game-of-thrones")
                .seasons()
                .extend(.Min)
                .perform()

            #expect(seasons.count == 5)
        }

        @Test func getAllSeasonsAndEpisodes() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons?extended=episodes", result: .success(jsonData(named: "test_get_all_seasons_and_episodes")))

            let seasons = try await traktManager
                .show(id: "game-of-thrones")
                .seasons()
                .extend(.Episodes)
                .perform()

            #expect(seasons.count == 6)
        }

        // MARK: - Season

        @Test func getSeason() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1?extended=min", result: .success(jsonData(named: "test_get_season")))

            let episodes = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .episodes()
                .extend(.Min)
                .perform()

            #expect(episodes.count == 10)
        }

        @Test func getTranslatedSeason() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1?extended=min&translations=es", result: .success(jsonData(named: "test_get_season")))

            let episodes = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .episodes(translations: "es")
                .extend(.Min)
                .perform()

            #expect(episodes.count == 10)
        }

        // MARK: - Comments

        @Test func getSeasonComments() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/comments", result: .success(jsonData(named: "test_get_season_comments")))

            let comments = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .comments()
                .perform()

            #expect(comments.count == 1)
        }

        // MARK: - Lists

        @Test func getListsContainingSeason() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/lists/personal/added", result: .success(jsonData(named: "test_get_lists_containing_season")))

            let lists = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .containingLists(type: ListType.personal.rawValue, sort: ListSortType.added.rawValue)
                .perform()

            #expect(lists.object.count == 1)
        }

        // MARK: - Ratings

        @Test func getSeasonRating() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/ratings", result: .success(jsonData(named: "test_get_season_rating")))

            let ratings = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .ratings()
                .perform()

            #expect(ratings.rating == 9)
            #expect(ratings.votes == 3)
            #expect(ratings.distribution.ten == 2)
        }

        // MARK: - Stats

        @Test func getSeasonStats() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/stats", result: .success(jsonData(named: "test_get_season_stats")))

            let stats = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .stats()
                .perform()

            #expect(stats.watchers == 30521)
            #expect(stats.plays == 37986)
            #expect(stats.collectors == 12899)
            #expect(stats.collectedEpisodes == 87991)
            #expect(stats.comments == 115)
            #expect(stats.lists == 309)
            #expect(stats.votes == 25655)
        }

        // MARK: - Watching

        @Test func getUsersWatchingSeason() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/watching", result: .success(jsonData(named: "test_get_users_watching_season")))

            let users = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .usersWatching()
                .perform()

            #expect(users.count == 2)
        }

        // MARK: - People

        @Test func getShowPeopleMin() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/people?extended=min", result: .success(jsonData(named: "test_get_season_cast")))

            let castAndCrew = try await traktManager
                .show(id: "game-of-thrones")
                .season(1)
                .people()
                .extend(.Min)
                .perform()

            #expect(castAndCrew.cast != nil)
            #expect(castAndCrew.producers != nil)
            #expect(castAndCrew.cast!.count == 20)
            #expect(castAndCrew.producers!.count == 14)

            guard let actor = castAndCrew.cast?.first else {
                Issue.record("Cast is empty")
                return
            }
            #expect(actor.person.name == "Emilia Clarke")
            #expect(actor.characters == ["Daenerys Targaryen"])
        }
    }
}
