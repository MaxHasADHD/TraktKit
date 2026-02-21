//
//  SeasonTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/28/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

final class SeasonTests: TraktTestCase {

    // MARK: - Summary

    func test_get_all_seasons() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons?extended=min", result: .success(jsonData(named: "test_get_all_seasons")))

        let expectation = XCTestExpectation(description: "Get all seasons")
        traktManager.getSeasons(showID: "game-of-thrones") { result in
            if case .success(let seasons) = result {
                XCTAssertEqual(seasons.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_all_seasons_and_episodes() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons?extended=episodes", result: .success(jsonData(named: "test_get_all_seasons_and_episodes")))

        let expectation = XCTestExpectation(description: "Get all seasons and episodes")
        traktManager.getSeasons(showID: "game-of-thrones", extended: [.Episodes]) { result in
            if case .success(let seasons) = result {
                XCTAssertEqual(seasons.count, 6)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Season

    func test_get_season() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1?extended=min", result: .success(jsonData(named: "test_get_season")))

        let expectation = XCTestExpectation(description: "Get all seasons and episodes")
        traktManager.getEpisodesForSeason(showID: "game-of-thrones", season: 1) { result in
            if case .success(let episodes) = result {
                XCTAssertEqual(episodes.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_translated_season() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1?extended=min&translations=es", result: .success(jsonData(named: "test_get_season")))

        let expectation = XCTestExpectation(description: "Get translated episodes")
        traktManager.getEpisodesForSeason(showID: "game-of-thrones", season: 1, translatedInto: "es") { result in
            if case .success(let episodes) = result {
                XCTAssertEqual(episodes.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comments

    func test_get_season_comments() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/comments", result: .success(jsonData(named: "test_get_season_comments")))

        let expectation = XCTestExpectation(description: "Get season comments")
        traktManager.getAllSeasonComments(showID: "game-of-thrones", season: 1) { result in
            if case .success(let comments, _, _) = result {
                XCTAssertEqual(comments.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_lists_containing_season() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/lists/personal/added", result: .success(jsonData(named: "test_get_lists_containing_season")))

        let expectation = XCTestExpectation(description: "Get lists containing season")
        traktManager.getListsContainingSeason(showID: "game-of-thrones", season: 1, listType: ListType.personal, sortBy: .added) { result in
            if case .success(let lists, _, _) = result {
                XCTAssertEqual(lists.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Ratings

    func test_get_season_rating() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/ratings", result: .success(jsonData(named: "test_get_season_rating")))

        let expectation = XCTestExpectation(description: "Get season ratings")
        traktManager.getSeasonRatings(showID: "game-of-thrones", season: 1) { result in
            if case .success(let ratings) = result {
                XCTAssertEqual(ratings.rating, 9)
                XCTAssertEqual(ratings.votes, 3)
                XCTAssertEqual(ratings.distribution.ten, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Stats

    func test_get_season_stats() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/stats", result: .success(jsonData(named: "test_get_season_stats")))

        let expectation = XCTestExpectation(description: "Get season stats")
        traktManager.getSeasonStatistics(showID: "game-of-thrones", season: 1) { result in
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
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watching

    func test_get_users_watching_season() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/watching", result: .success(jsonData(named: "test_get_users_watching_season")))

        let expectation = XCTestExpectation(description: "Get users watching season")
        traktManager.getUsersWatchingSeasons(showID: "game-of-thrones", season: 1) { result in
            if case .success(let users) = result {
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    // MARK: - People
    
    func test_get_show_people_min() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/people?extended=min", result: .success(jsonData(named: "test_get_season_cast")))
        
        let expectation = XCTestExpectation(description: "ShowCastAndCrew")
        traktManager.getPeopleInSeason(showID: "game-of-thrones", season: 1) { result in
            if case .success(let castAndCrew) = result {
                XCTAssertNotNil(castAndCrew.cast)
                XCTAssertNotNil(castAndCrew.producers)
                XCTAssertEqual(castAndCrew.cast!.count, 20)
                XCTAssertEqual(castAndCrew.producers!.count, 14)
                
                guard let actor = castAndCrew.cast?.first else { XCTFail("Cast is empty"); return }
                XCTAssertEqual(actor.person.name, "Emilia Clarke")
                XCTAssertEqual(actor.characters, ["Daenerys Targaryen"])
            }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
                
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
