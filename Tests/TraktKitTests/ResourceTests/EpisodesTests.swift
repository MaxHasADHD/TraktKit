//
//  EpisodeTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Testing
import Foundation
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Episode Tests")
    struct EpisodeTests {
        let traktManager: TraktManager

        init() async throws {
            self.traktManager = await authenticatedTraktManager()
        }

        // MARK: - Summary

        @Test func getMinEpisode() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1?extended=min", result: .success(jsonData(named: "Episode_Min")))

            let episode = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .summary()
                .extend(.Min)
                .perform()

            #expect(episode.title == "Winter Is Coming")
            #expect(episode.season == 1)
            #expect(episode.number == 1)
            #expect(episode.ids.trakt == 36440)
        }

        @Test func getFullEpisode() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1?extended=full", result: .success(jsonData(named: "Episode_Full")))

            let episode = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .summary()
                .extend(.Full)
                .perform()

            #expect(episode.title == "Winter Is Coming")
            #expect(episode.season == 1)
            #expect(episode.number == 1)
            #expect(episode.ids.trakt == 36440)
            #expect(episode.overview != nil)
            #expect(episode.firstAired != nil)
            #expect(episode.updatedAt != nil)
            #expect(episode.availableTranslations == ["en"])
        }

        @Test func getEpisodeImages() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/severance/seasons/2/episodes/5?extended=images", result: .success(jsonData(named: "Episode_Images")))

            let episode = try await traktManager
                .show(id: "severance")
                .season(2).episode(5)
                .summary()
                .extend(.images)
                .perform()

            #expect(episode.title == "Trojan's Horse")
            #expect(episode.season == 2)
            #expect(episode.number == 5)
            #expect(episode.ids.trakt == 12103031)
            #expect(episode.overview == nil)
            #expect(episode.firstAired == nil)
            #expect(episode.updatedAt == nil)
            #expect(episode.absoluteNumber == nil)
            #expect(episode.availableTranslations == nil)
        }

        // MARK: - Translations

        @Test func getAllEpisodeTranslations() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/translations", result: .success(jsonData(named: "test_get_all_episode_translations")))

            let translations = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .translations()
                .perform()

            #expect(translations.count == 3)
        }

        // MARK: - Comments

        @Test func getEpisodeComments() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/comments", result: .success(jsonData(named: "test_get_episode_comments")))

            let comments = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .comments()
                .perform()

            #expect(comments.count == 1)
        }

        // MARK: - Lists

        @Test func getListsContainingEpisode() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/lists/official/added?extended=full", result: .success(jsonData(named: "test_get_lists_containing_episode")))

            let route = traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .containingLists()
                .listType(.official)
                .sort(by: .added)
                .extend(.Full)

            #expect(route.path == "shows/game-of-thrones/seasons/1/episodes/1/lists/official/added")

            let lists = try await route.perform()
            #expect(lists.count == 1)
        }

        // MARK: - Ratings

        @Test func getEpisodeRatings() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/ratings", result: .success(jsonData(named: "test_get_episode_ratings")))

            let rating = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .ratings()
                .perform()

            #expect(rating.rating == 9)
            #expect(rating.votes == 3)
        }

        // MARK: - Stats

        @Test func getEpisodeStats() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/stats", result: .success(jsonData(named: "test_get_episode_stats")))

            let stats = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
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

        @Test func getUsersWatchingNow() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/watching", result: .success(jsonData(named: "test_get_users_watching_now")))

            let watchers = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .usersWatching()
                .perform()

            #expect(watchers.count == 2)
        }

        // MARK: - People

        @Test func getShowPeopleMin() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/people?extended=min", result: .success(jsonData(named: "test_get_episode_cast")))

            let castAndCrew = try await traktManager
                .show(id: "game-of-thrones")
                .season(1).episode(1)
                .people()
                .extend(.Min)
                .perform()

            #expect(castAndCrew.cast != nil)
            #expect(castAndCrew.writers != nil)
            #expect(castAndCrew.cast!.count == 20)
            #expect(castAndCrew.writers!.count == 2)

            guard let actor = castAndCrew.cast?.first else {
                Issue.record("Cast is empty")
                return
            }
            #expect(actor.person.name == "Emilia Clarke")
            #expect(actor.characters == ["Daenerys Targaryen"])
        }
    }
}
