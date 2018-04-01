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

    let session = MockURLSession()
    lazy var traktManager = TraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Trending

    func test_get_min_trending_shows() {
        session.nextData = jsonData(named: "TrendingShows_Min")

        let expectation = XCTestExpectation(description: "TrendingShows")
        traktManager.getTrendingShows(page: 1, limit: 10) { result in
            if case .success(let trendingShows) = result {
                XCTAssertEqual(trendingShows.count, 10)
                expectation.fulfill()
            }
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
        session.nextData = jsonData(named: "TrendingShows_Full")

        let expectation = XCTestExpectation(description: "TrendingShows")
        traktManager.getTrendingShows(page: 1, limit: 10, extended: [.Full]) { result in
            if case .success(let trendingShows) = result {
                XCTAssertEqual(trendingShows.count, 10)
                expectation.fulfill()
            }
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

    // MARK: - Popular

    func test_get_popular_shows() {
        session.nextData = jsonData(named: "test_get_popular_shows")

        let expectation = XCTestExpectation(description: "Get popular shows")
        traktManager.getPopularShows(page: 1, limit: 10) { result in
            if case .success(let popularShows) = result {
                XCTAssertEqual(popularShows.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/popular?page=1&limit=10&extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Played

    func test_get_most_played_shows() {
        session.nextData = jsonData(named: "test_get_most_played_shows")

        let expectation = XCTestExpectation(description: "Get most played shows")
        traktManager.getPlayedShows(page: 1, limit: 10) { result in
            if case .success(let playedShows) = result {
                XCTAssertEqual(playedShows.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/played/weekly?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watched

    func test_get_most_watched_shows() {
        session.nextData = jsonData(named: "test_get_most_watched_shows")

        let expectation = XCTestExpectation(description: "Get most watched shows")
        traktManager.getWatchedShows(page: 1, limit: 10) { result in
            if case .success(let watchedShows) = result {
                XCTAssertEqual(watchedShows.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/watched/weekly?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Collected

    func test_get_most_collected_shows() {
        session.nextData = jsonData(named: "test_get_most_collected_shows")

        let expectation = XCTestExpectation(description: "Get most collected shows")
        traktManager.getCollectedShows(page: 1, limit: 10) { result in
            if case .success(let collectedShows) = result {
                XCTAssertEqual(collectedShows.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/collected/weekly?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Anticipated

    func test_get_most_anticipated_shows() {
        session.nextData = jsonData(named: "test_get_most_anticipated_shows")

        let expectation = XCTestExpectation(description: "Get anticipated shows")
        traktManager.getAnticipatedShows(page: 1, limit: 10) { result in
            if case .success(let anticipatedShows) = result {
                XCTAssertEqual(anticipatedShows.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/anticipated?page=1&limit=10&extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Updates

    func test_get_updated_shows() {
        session.nextData = jsonData(named: "test_get_updated_shows")

        let expectation = XCTestExpectation(description: "Get updated shows")
        traktManager.getUpdatedShows(page: 1, limit: 10, startDate: try! Date.dateFromString("2014-09-22")) { result in
            if case .success(let shows) = result {
                XCTAssertEqual(shows.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/updates/2014-09-22?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Summary

    func test_get_min_show() {
        session.nextData = jsonData(named: "Show_Min")

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
                expectation.fulfill()
            }
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
        session.nextData = jsonData(named: "Show_Full")

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
                expectation.fulfill()
            }
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

    // MARK: - Aliases

    func test_get_show_aliases() {
        session.nextData = jsonData(named: "ShowAliases")

        let expectation = XCTestExpectation(description: "ShowAliases")
        traktManager.getShowAliases(showID: "game-of-thrones") { result in
            if case .success(let aliases) = result {
                XCTAssertEqual(aliases.count, 32)
                expectation.fulfill()
            }
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

    // MARK: - Translations

    func test_get_show_translations() {
        session.nextData = jsonData(named: "test_get_show_translations")

        let expectation = XCTestExpectation(description: "Get show translations")
        traktManager.getShowTranslations(showID: "game-of-thrones", language: "es") { result in
            if case .success(let translations) = result {
                XCTAssertEqual(translations.count, 3)
                expectation.fulfill()
            }
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/translations/es")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comments

    func test_get_show_comments() {
        session.nextData = jsonData(named: "test_get_show_comments")

        let expectation = XCTestExpectation(description: "Get show comments")
        traktManager.getShowComments(showID: "game-of-thrones") { result in
            if case .success(let comments) = result {
                XCTAssertEqual(comments.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/comments")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_lists_containing_show() {
        session.nextData = jsonData(named: "test_get_lists_containing_show")

        let expectation = XCTestExpectation(description: "Get lists containing shows")
        traktManager.getListsContainingShow(showID: "game-of-thrones") { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/lists")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Collection Progress

    func testParseShowCollectionProgress() {
        session.nextData = jsonData(named: "ShowCollectionProgress")

        let expectation = XCTestExpectation(description: "Get collected progress")
        traktManager.getShowCollectionProgress(showID: "game-of-thrones") { result in
            if case .success(let collectionProgress) = result {
                XCTAssertEqual(collectionProgress.aired, 8)
                XCTAssertEqual(collectionProgress.completed, 6)
                XCTAssertEqual(collectionProgress.seasons.count, 1)

                let season = collectionProgress.seasons[0]
                XCTAssertEqual(season.number, 1)
                XCTAssertEqual(season.aired, 8)
                XCTAssertEqual(season.completed, 6)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/progress/collection?hidden=false&specials=false")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watched Progress

    func test_get_wathced_progress() {
        session.nextData = jsonData(named: "test_get_wathced_progress")

        let expectation = XCTestExpectation(description: "Get watched progress")
        traktManager.getShowWatchedProgress(showID: "game-of-thrones") { result in
            if case .success(let progress) = result {
                XCTAssertEqual(progress.completed, 6)
                XCTAssertEqual(progress.aired, 8)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/progress/watched?hidden=false&specials=false")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - People

    func test_get_show_people() {
        session.nextData = jsonData(named: "ShowCastAndCrew_Min")

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

    // MARK: - Ratings

    func test_get_show_ratings() {
        session.nextData = jsonData(named: "test_get_show_ratings")

        let expectation = XCTestExpectation(description: "Get show ratings")
        traktManager.getShowRatings(showID: "game-of-thrones") { result in
            if case .success(let ratings) = result {
                XCTAssertEqual(ratings.rating, 9.38363)
                XCTAssertEqual(ratings.votes, 51065)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/ratings")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Related

    func test_get_related_shows() {
        session.nextData = jsonData(named: "test_get_related_shows")

        let expectation = XCTestExpectation(description: "Get related shows")
        traktManager.getRelatedShows(showID: "game-of-thrones") { result in
            if case .success(let relatedShows) = result {
                XCTAssertEqual(relatedShows.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/related?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Stats

    func test_get_stats() {
        session.nextData = jsonData(named: "ShowStats")

        let expectation = XCTestExpectation(description: "Stats")
        traktManager.getShowStatistics(showID: "game-of-thrones") { result in
            if case .success(let stats) = result {
                XCTAssertEqual(stats.comments, 298)
                XCTAssertEqual(stats.lists, 221719)
                XCTAssertEqual(stats.votes, 72920)
                XCTAssertEqual(stats.collectors, 710781)
                XCTAssertEqual(stats.collectedEpisodes, 36532224)
                XCTAssertEqual(stats.watchers, 610988)
                expectation.fulfill()
            }
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

    // MARK: - Watching

    func test_get_users_watching_show() {
        session.nextData = jsonData(named: "test_get_users_watching_show")

        let expectation = XCTestExpectation(description: "Get users watching the show")
        traktManager.getUsersWatchingShow(showID: "game-of-thrones") { result in
            if case .success(let users) = result {
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/watching")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Next episode

    func test_get_nextEpisode() {
        // TODO: Add success with status code, and move `createErrorWithStatusCode` outside TraktManager
        session.nextError = traktManager.createErrorWithStatusCode(204)

        let expectation = XCTestExpectation(description: "NextEpisode")
        traktManager.getNextEpisode(showID: "game-of-thrones") { result in
            if case .error(let error) = result {
                XCTAssertNotNil(error)
                XCTAssertEqual(error!._code, 204)
                expectation.fulfill()
            } else { XCTFail("Unexpected result") }
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

    // MARK: - Last episode

    func test_get_lastEpisode() {
        session.nextData = jsonData(named: "LastEpisodeAired_min")

        let expectation = XCTestExpectation(description: "LastEpisode")
        traktManager.getLastEpisode(showID: "game-of-thrones") { result in
            if case .success(let episode) = result {
                XCTAssertEqual(episode.title, "The Dragon and the Wolf")
                XCTAssertEqual(episode.season, 7)
                XCTAssertEqual(episode.number, 7)
                expectation.fulfill()
            }
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

}
