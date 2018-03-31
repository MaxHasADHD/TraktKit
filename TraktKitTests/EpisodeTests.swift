//
//  EpisodeTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class EpisodeTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Summary

    func test_get_min_episode() {
        session.nextData = jsonData(named: "Episode_Min")

        let expectation = XCTestExpectation(description: "EpisodeSummary")
        traktManager.getEpisodeSummary(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1) { result in
            if case .success(let episode) = result {
                XCTAssertEqual(episode.title, "Winter Is Coming")
                XCTAssertEqual(episode.season, 1)
                XCTAssertEqual(episode.number, 1)
                XCTAssertEqual(episode.ids.trakt, 36440)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_episode() {
        session.nextData = jsonData(named: "Episode_Full")

        let expectation = XCTestExpectation(description: "EpisodeSummary")
        traktManager.getEpisodeSummary(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1, extended: [.Full]) { result in
            if case .success(let episode) = result {
                XCTAssertEqual(episode.title, "Winter Is Coming")
                XCTAssertEqual(episode.season, 1)
                XCTAssertEqual(episode.number, 1)
                XCTAssertEqual(episode.ids.trakt, 36440)
                XCTAssertNotNil(episode.overview)
                XCTAssertNotNil(episode.firstAired)
                XCTAssertNotNil(episode.updatedAt)
                XCTAssertEqual(episode.availableTranslations!, ["en"])
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Translations

    func test_get_all_episode_translations() {
        session.nextData = jsonData(named: "test_get_all_episode_translations")

        let expectation = XCTestExpectation(description: "Get episode translations")
        traktManager.getEpisodeTranslations(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1) { result in
            if case .success(let translations) = result {
                XCTAssertEqual(translations.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/translations")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comments

    func test_get_episode_comments() {
        session.nextData = jsonData(named: "test_get_episode_comments")

        let expectation = XCTestExpectation(description: "Get episode comments")
        traktManager.getEpisodeComments(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1) { result in
            if case .success(let comments) = result {
                XCTAssertEqual(comments.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/comments")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_lists_containing_episode() {
        session.nextData = jsonData(named: "test_get_lists_containing_episode")

        let expectation = XCTestExpectation(description: "Get lists containing episode")
        traktManager.getListsContainingEpisode(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1, listType: .official, sortBy: .added) { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/lists/official/added")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Ratings

    func test_get_episode_ratings() {
        session.nextData = jsonData(named: "test_get_episode_ratings")

        let expectation = XCTestExpectation(description: "Get episode ratings")
        traktManager.getEpisodeRatings(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1) { result in
            if case .success(let rating) = result {
                XCTAssertEqual(rating.rating, 9)
                XCTAssertEqual(rating.votes, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/ratings")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Stats

    func test_get_episode_stats() {
        session.nextData = jsonData(named: "test_get_episode_stats")

        let expectation = XCTestExpectation(description: "Get episode stats")
        traktManager.getEpisodeStatistics(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1) { result in
            if case .success(let stats) = result {
                XCTAssertEqual(stats.watchers, 30521)
                XCTAssertEqual(stats.plays, 37986)
                XCTAssertEqual(stats.collectors, 12899)
                XCTAssertEqual(stats.collectedEpisodes, 87991)
                XCTAssertEqual(stats.comments, 115)
                XCTAssertEqual(stats.lists, 309)
                XCTAssertEqual(stats.votes, 25655)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/stats")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watching

    func test_get_users_watching_now() {
        session.nextData = jsonData(named: "test_get_users_watching_now")

        let expectation = XCTestExpectation(description: "Get users watching episode")
        traktManager.getUsersWatchingEpisode(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1) { result in
            if case .success(let watchers) = result {
                XCTAssertEqual(watchers.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1/watching")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
