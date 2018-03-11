//
//  ShowsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class ShowsTests: XCTestCase {

    func test_get_min_show() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Show_Min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "ShowSummary")
        traktManager.getShowSummary(showID: "game-of-thrones") { result in
            if case .success(let show) = result {
                XCTAssertEqual(show.title, "Game of Thrones")
                XCTAssertEqual(show.year, 2011)
                XCTAssertEqual(show.ids.trakt, 353)
                XCTAssertEqual(show.ids.slug, "game-of-thrones")
                XCTAssertNil(show.overview)
                XCTAssertNil(show.firstAired)
                XCTAssertNil(show.airs)
                XCTAssertNil(show.runtime)
                XCTAssertNil(show.certification)
                XCTAssertNil(show.network)
                XCTAssertNil(show.country)
                XCTAssertNil(show.trailer)
                XCTAssertNil(show.homepage)
                XCTAssertNil(show.status)
                XCTAssertNil(show.rating)
                XCTAssertNil(show.votes)
                XCTAssertNil(show.updatedAt)
                XCTAssertNil(show.language)
                XCTAssertNil(show.availableTranslations)
                XCTAssertNil(show.genres)
                XCTAssertNil(show.airedEpisodes)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_show() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Show_Full")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "ShowSummary")
        traktManager.getShowSummary(showID: "game-of-thrones", extended: [.Full]) { result in
            if case .success(let show) = result {
                XCTAssertEqual(show.title, "Game of Thrones")
                XCTAssertEqual(show.year, 2011)
                XCTAssertEqual(show.ids.trakt, 353)
                XCTAssertEqual(show.ids.slug, "game-of-thrones")
                XCTAssertNotNil(show.overview)
                XCTAssertNotNil(show.firstAired)
                XCTAssertEqual(show.airs?.day, "Sunday")
                XCTAssertEqual(show.airs?.time, "21:00")
                XCTAssertEqual(show.airs?.timezone, "America/New_York")
                XCTAssertEqual(show.runtime, 60)
                XCTAssertEqual(show.certification, "TV-MA")
                XCTAssertEqual(show.network, "HBO")
                XCTAssertEqual(show.country, "us")
                XCTAssertNotNil(show.updatedAt)
                XCTAssertNil(show.trailer)
                XCTAssertEqual(show.homepage?.absoluteString, "http://www.hbo.com/game-of-thrones/index.html")
                XCTAssertEqual(show.status, "returning series")
                XCTAssertEqual(show.language, "en")
                XCTAssertEqual(show.availableTranslations?.count, 18)
                XCTAssertEqual(show.genres!, ["drama", "fantasy"])
                XCTAssertEqual(show.airedEpisodes, 50)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_min_trending_shows() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "TrendingShows_Min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "TrendingShows")
        traktManager.getTrendingShows(page: 1, limit: 10) { result in
            if case .success(let trendingShows) = result {
                XCTAssertEqual(trendingShows.count, 10)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/trending?page=1&limit=10&extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_trending_shows() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "TrendingShows_Full")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "TrendingShows")
        traktManager.getTrendingShows(page: 1, limit: 10, extended: [.Full]) { result in
            if case .success(let trendingShows) = result {
                XCTAssertEqual(trendingShows.count, 10)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/trending?page=1&limit=10&extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_show_aliases() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "ShowAliases")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "ShowAliases")
        traktManager.getShowAliases(showID: "game-of-thrones") { result in
            if case .success(let aliases) = result {
                XCTAssertEqual(aliases.count, 32)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/aliases")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_show_people() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "ShowCastAndCrew_Min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "ShowCastAndCrew")
        traktManager.getPeopleInShow(showID: "game-of-thrones") { result in
            if case .success(let castAndCrew) = result {
                XCTAssertNotNil(castAndCrew.cast)
                XCTAssertNotNil(castAndCrew.producers)
                XCTAssertEqual(castAndCrew.cast!.count, 27)
                XCTAssertEqual(castAndCrew.producers!.count, 15)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/people?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_nextEpisode() {
        let session = MockURLSession()
        let traktManager = TraktManager(session: session)
        // TODO: Add success with status code, and move `createErrorWithStatusCode` outside TraktManager
        session.nextError = traktManager.createErrorWithStatusCode(204)

        let expectation = XCTestExpectation(description: "NextEpisode")
        traktManager.getNextEpisode(showID: "game-of-thrones") { result in
            if case .error(let error) = result {
                XCTAssertNotNil(error)
                XCTAssertEqual(error!._code, 204)
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/next_episode?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_lastEpisode() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "LastEpisodeAired_min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "LastEpisode")
        traktManager.getLastEpisode(showID: "game-of-thrones") { result in
            if case .success(let episode) = result {
                XCTAssertEqual(episode.title, "The Dragon and the Wolf")
                XCTAssertEqual(episode.season, 7)
                XCTAssertEqual(episode.number, 7)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/last_episode?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_stats() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "ShowStats")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "Stats")
        traktManager.getShowStatistics(showID: "game-of-thrones") { result in
            if case .success(let stats) = result {
                XCTAssertEqual(stats.comments, 298)
                XCTAssertEqual(stats.lists, 221719)
                XCTAssertEqual(stats.votes, 72920)
                XCTAssertEqual(stats.collectors, 710781)
                XCTAssertEqual(stats.collectedEpisodes, 36532224)
                XCTAssertEqual(stats.watchers, 610988)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/stats")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func testParseShowCollectionProgress() {
        guard let collectionProgress = decode("ShowCollectionProgress", to: ShowCollectionProgress.self) else { return }
        XCTAssertEqual(collectionProgress.aired, 8)
        XCTAssertEqual(collectionProgress.completed, 6)
        XCTAssertEqual(collectionProgress.seasons.count, 1)

        let season = collectionProgress.seasons[0]
        XCTAssertEqual(season.number, 1)
        XCTAssertEqual(season.aired, 8)
        XCTAssertEqual(season.completed, 6)
    }
}
