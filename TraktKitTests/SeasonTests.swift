//
//  SeasonTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/28/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class SeasonTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Summary

    func test_get_all_seasons() {
        session.nextData = jsonData(named: "test_get_all_seasons")

        let expectation = XCTestExpectation(description: "Get all seasons")
        traktManager.getSeasons(showID: "game-of-thrones") { result in
            if case .success(let seasons) = result {
                XCTAssertEqual(seasons.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_all_seasons_and_episodes() {
        session.nextData = jsonData(named: "test_get_all_seasons_and_episodes")

        let expectation = XCTestExpectation(description: "Get all seasons and episodes")
        traktManager.getSeasons(showID: "game-of-thrones", extended: [.Episodes]) { result in
            if case .success(let seasons) = result {
                XCTAssertEqual(seasons.count, 6)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons?extended=episodes")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Season

    func test_get_season() {
        session.nextData = jsonData(named: "test_get_season")

        let expectation = XCTestExpectation(description: "Get all seasons and episodes")
        traktManager.getEpisodesForSeason(showID: "game-of-thrones", season: 1) { result in
            if case .success(let episodes) = result {
                XCTAssertEqual(episodes.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_translated_season() {
        session.nextData = jsonData(named: "test_get_season")

        let expectation = XCTestExpectation(description: "Get translated episodes")
        traktManager.getEpisodesForSeason(showID: "game-of-thrones", season: 1, translatedInto: "es") { result in
            if case .success(let episodes) = result {
                XCTAssertEqual(episodes.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.path, "/shows/game-of-thrones/seasons/1")
        XCTAssertTrue(session.lastURL?.query?.contains("translations=es") ?? false)
        XCTAssertTrue(session.lastURL?.query?.contains("extended=min") ?? false)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comments

    func test_get_season_comments() {
        session.nextData = jsonData(named: "test_get_season_comments")

        let expectation = XCTestExpectation(description: "Get season comments")
        traktManager.getAllSeasonComments(showID: "game-of-thrones", season: 1) { result in
            if case .success(let comments, _, _) = result {
                XCTAssertEqual(comments.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/comments")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_lists_containing_season() {
        session.nextData = jsonData(named: "test_get_lists_containing_season")

        let expectation = XCTestExpectation(description: "Get lists containing season")
        traktManager.getListsContainingSeason(showID: "game-of-thrones", season: 1, listType: ListType.personal, sortBy: .added) { result in
            if case .success(let lists, _, _) = result {
                XCTAssertEqual(lists.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/lists/personal/added")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Ratings

    func test_get_season_rating() {
        session.nextData = jsonData(named: "test_get_season_rating")

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
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/ratings")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Stats

    func test_get_season_stats() {
        session.nextData = jsonData(named: "test_get_season_stats")

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
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/stats")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watching

    func test_get_users_watching_season() {
        session.nextData = jsonData(named: "test_get_users_watching_season")

        let expectation = XCTestExpectation(description: "Get users watching season")
        traktManager.getUsersWatchingSeasons(showID: "game-of-thrones", season: 1) { result in
            if case .success(let users) = result {
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/watching")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    // MARK: - People
    
    func test_get_show_people_min() {
        session.nextData = jsonData(named: "test_get_season_cast")
        
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
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/people?extended=min")
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
