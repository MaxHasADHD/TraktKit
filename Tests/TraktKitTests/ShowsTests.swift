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

final class ShowsTests: TraktTestCase {

    // MARK: - Trending

    func test_get_min_trending_shows_await() async throws {
        try mock(.GET, "https://api.trakt.tv/shows/trending?extended=min&page=1&limit=10", result: .success(jsonData(named: "TrendingShows_Min")), headers: [.page(1), .pageCount(100)])

        let response = try await traktManager.shows.trending()
            .extend(.Min)
            .page(1)
            .limit(10)
            .perform()
        let trendingShows = response.object
        XCTAssertEqual(trendingShows.count, 10)
        XCTAssertEqual(response.currentPage, 1)
        XCTAssertEqual(response.pageCount, 100)
        let firstTrendingShow = try XCTUnwrap(trendingShows.first)
        XCTAssertEqual(firstTrendingShow.watchers, 252)
        XCTAssertEqual(firstTrendingShow.show.title, "Marvel's Jessica Jones")
        XCTAssertNil(firstTrendingShow.show.overview)
    }

    func test_get_min_trending_shows() {
        try? mock(.GET, "https://api.trakt.tv/shows/trending?extended=min&page=1&limit=10", result: .success(jsonData(named: "TrendingShows_Min")))

        let expectation = XCTestExpectation(description: "TrendingShows")
        traktManager.getTrendingShows(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let trendingShows, _, _) = result {
                do {
                    XCTAssertEqual(trendingShows.count, 10)
                    let firstTrendingShow = try XCTUnwrap(trendingShows.first)
                    XCTAssertEqual(firstTrendingShow.watchers, 252)
                    XCTAssertEqual(firstTrendingShow.show.title, "Marvel's Jessica Jones")
                    XCTAssertNil(firstTrendingShow.show.overview)
                } catch {
                    XCTFail("Something isn't working")
                }
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

    func test_get_full_trending_shows() {
        try? mock(.GET, "https://api.trakt.tv/shows/trending?extended=full&page=1&limit=10", result: .success(jsonData(named: "TrendingShows_Full")))

        let expectation = XCTestExpectation(description: "TrendingShows")
        traktManager.getTrendingShows(pagination: Pagination(page: 1, limit: 10), extended: [.Full]) { result in
            if case .success(let trendingShows, _, _) = result {
                do {
                    XCTAssertEqual(trendingShows.count, 10)
                    let firstTrendingShow = try XCTUnwrap(trendingShows.first)
                    XCTAssertEqual(firstTrendingShow.watchers, 252)
                    XCTAssertEqual(firstTrendingShow.show.title, "Marvel's Jessica Jones")
                    XCTAssertEqual(firstTrendingShow.show.overview, "A former superhero decides to reboot her life by becoming a private investigator.")
                } catch {
                    XCTFail("Something isn't working")
                }
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

    // MARK: - Popular

    func test_get_popular_shows() {
        try? mock(.GET, "https://api.trakt.tv/shows/popular?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_popular_shows")))

        let expectation = XCTestExpectation(description: "Get popular shows")
        traktManager.getPopularShows(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let popularShows, _, _) = result {
                XCTAssertEqual(popularShows.count, 10)
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

    // MARK: - Played

    func test_get_most_played_shows() {
        try? mock(.GET, "https://api.trakt.tv/shows/played/weekly?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_played_shows")))

        let expectation = XCTestExpectation(description: "Get most played shows")
        traktManager.getPlayedShows(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let playedShows, _, _) = result {
                XCTAssertEqual(playedShows.count, 10)
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

    // MARK: - Watched

    func test_get_most_watched_shows() {
        try? mock(.GET, "https://api.trakt.tv/shows/watched/weekly?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_watched_shows")))

        let expectation = XCTestExpectation(description: "Get most watched shows")
        traktManager.getWatchedShows(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let watchedShows, _, _) = result {
                XCTAssertEqual(watchedShows.count, 10)
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

    func test_get_most_watched_shows_async() async throws {
        try? mock(.GET, "https://api.trakt.tv/shows/watched/weekly?page=1&limit=10", result: .success(jsonData(named: "test_get_most_watched_shows")), headers: [.page(1), .pageCount(8)])

        let pagedObject = try await traktManager.shows
            .watched(period: .weekly)
            .page(1)
            .limit(10)
            .perform()
        let (watchedShows, page, total) = (pagedObject.object, pagedObject.currentPage, pagedObject.pageCount)

        XCTAssertEqual(watchedShows.count, 10)
        XCTAssertEqual(page, 1)
        XCTAssertEqual(total, 8)
        let firstWatchedShow = try XCTUnwrap(watchedShows.first)
        XCTAssertEqual(firstWatchedShow.playCount, 8784154)
        XCTAssertEqual(firstWatchedShow.watcherCount, 203742)
    }

    // MARK: - Collected

    func test_get_most_collected_shows() {
        try? mock(.GET, "https://api.trakt.tv/shows/collected/weekly?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_collected_shows")))

        let expectation = XCTestExpectation(description: "Get most collected shows")
        traktManager.getCollectedShows(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let collectedShows, _, _) = result {
                XCTAssertEqual(collectedShows.count, 10)
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

    // MARK: - Anticipated

    func test_get_most_anticipated_shows() {
        try? mock(.GET, "https://api.trakt.tv/shows/anticipated?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_anticipated_shows")))

        let expectation = XCTestExpectation(description: "Get anticipated shows")
        traktManager.getAnticipatedShows(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let anticipatedShows, _, _) = result {
                XCTAssertEqual(anticipatedShows.count, 10)
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

    // MARK: - Updates

    func test_get_updated_shows() throws {
        try mock(.GET, "https://api.trakt.tv/shows/updates/2014-09-22?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_updated_shows")))

        let expectation = XCTestExpectation(description: "Get updated shows")
        traktManager.getUpdatedShows(startDate: try Date.dateFromString("2014-09-22"), pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let shows, _, _) = result {
                XCTAssertEqual(shows.count, 2)
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

    func test_get_updated_show_ids() async throws {
        try mock(.GET, "https://api.trakt.tv/shows/updates/id/2025-01-01T00:00:00", result: .success(jsonData(named: "test_get_updated_shows_ids")))

        let updatedIds = try await traktManager.shows
            .recentlyUpdatedIds(since: try Date.dateFromString("2025-01-01"))
            .perform()
        XCTAssertEqual(updatedIds.object.count, 100)
        XCTAssertEqual(updatedIds.object.first, 163302)
    }

    // MARK: - Summary

    func test_get_min_show() {
        try? mock(.GET, "https://api.trakt.tv/shows/game-of-thrones?extended=min", result: .success(jsonData(named: "Show_Min")))

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

        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_show() {
        try? mock(.GET, "https://api.trakt.tv/shows/game-of-thrones?extended=full", result: .success(jsonData(named: "Show_Full")))

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

        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func test_get_full_show_await() async throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones?extended=full", result: .success(jsonData(named: "Show_Full")))
        
        let show = try await traktManager.show(id: "game-of-thrones").summary()
            .extend(.Full)
            .perform()
        
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

    // MARK: - Aliases

    func test_get_show_aliases() {
        try? mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/aliases", result: .success(jsonData(named: "ShowAliases")))

        let expectation = XCTestExpectation(description: "ShowAliases")
        traktManager.getShowAliases(showID: "game-of-thrones") { result in
            if case .success(let aliases) = result {
                XCTAssertEqual(aliases.count, 32)
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

    func test_get_show_aliases_await() async throws {
        try? mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/aliases", result: .success(jsonData(named: "ShowAliases")))

        let aliases = try await traktManager.show(id: "game-of-thrones").aliases().perform()
        XCTAssertEqual(aliases.count, 32)
    }

    // MARK: - Translations

    func test_get_show_translations() {
        try? mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/translations/es", result: .success(jsonData(named: "test_get_show_translations")))

        let expectation = XCTestExpectation(description: "Get show translations")
        traktManager.getShowTranslations(showID: "game-of-thrones", language: "es") { result in
            if case .success(let translations) = result {
                XCTAssertEqual(translations.count, 40)
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

    func test_get_show_comments() throws {
        try mock(.GET, "https://api.trakt.tv/shows/presumed-innocent/comments", result: .success(jsonData(named: "test_get_show_comments")))

        let expectation = XCTestExpectation(description: "Get show comments")
        traktManager.getShowComments(showID: "presumed-innocent") { result in
            if case .success(let comments, _, _) = result {
                XCTAssertEqual(comments.count, 10)
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

    func test_get_show_comments_async() async throws {
        try mock(.GET, "https://api.trakt.tv/shows/presumed-innocent/comments/newest", result: .success(jsonData(named: "test_get_show_comments")), headers: [.page(1), .pageCount(4)])

        let pagedObject = try await traktManager.show(id: "presumed-innocent")
            .comments(sort: "newest")
            .perform()
        let (watchedShows, page, total) = (pagedObject.object, pagedObject.currentPage, pagedObject.pageCount)

        XCTAssertEqual(watchedShows.count, 10)
        XCTAssertEqual(page, 1)
        XCTAssertEqual(total, 4)

        let firstComment = try XCTUnwrap(watchedShows.first)
        XCTAssertEqual(firstComment.comment, "I did NOT expect that ending. Wow! What a show!")
        XCTAssertEqual(firstComment.parentId, 0)
    }

    // MARK: - Lists

    func test_get_lists_containing_show() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/lists", result: .success(jsonData(named: "test_get_lists_containing_show")))

        let expectation = XCTestExpectation(description: "Get lists containing shows")
        traktManager.getListsContainingShow(showID: "game-of-thrones") { result in
            if case .success(let lists) = result {
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

    // MARK: - Collection Progress

    func testParseShowCollectionProgress() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/progress/collection?hidden=false&specials=false", result: .success(jsonData(named: "ShowCollectionProgress")))

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
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watched Progress

    func test_get_wathced_progress() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/progress/watched?hidden=false&specials=false", result: .success(jsonData(named: "test_get_wathced_progress")))

        let expectation = XCTestExpectation(description: "Get watched progress")
        traktManager.getShowWatchedProgress(showID: "game-of-thrones") { result in
            if case .success(let progress) = result {
                XCTAssertEqual(progress.completed, 6)
                XCTAssertEqual(progress.aired, 8)
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
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/people?extended=min", result: .success(jsonData(named: "ShowCastAndCrew_Min")))

        let expectation = XCTestExpectation(description: "ShowCastAndCrew")
        traktManager.getPeopleInShow(showID: "game-of-thrones") { result in
            if case .success(let castAndCrew) = result {
                XCTAssertNotNil(castAndCrew.cast)
                XCTAssertNotNil(castAndCrew.producers)
                XCTAssertEqual(castAndCrew.cast!.count, 43)
                XCTAssertEqual(castAndCrew.producers!.count, 24)
                
                guard let actor = castAndCrew.cast?.first else { XCTFail("Cast is empty"); return }
                XCTAssertEqual(actor.person.name, "Emilia Clarke")
                XCTAssertEqual(actor.characters, ["Daenerys Targaryen"])
            }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func test_get_show_people_full() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/people?extended=full", result: .success(jsonData(named: "ShowCastAndCrew_Full")))

        let expectation = XCTestExpectation(description: "ShowCastAndCrew")
        traktManager.getPeopleInShow(showID: "game-of-thrones", extended: [.Full]) { result in
            if case .success(let castAndCrew) = result {
                XCTAssertNotNil(castAndCrew.cast)
                XCTAssertNotNil(castAndCrew.producers)
                XCTAssertEqual(castAndCrew.cast!.count, 43)
                XCTAssertEqual(castAndCrew.producers!.count, 24)
            }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func test_get_show_people_guest_stars() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/people?extended=guest_stars", result: .success(jsonData(named: "ShowCastAndCrew_GuestStars")))

        let expectation = XCTestExpectation(description: "ShowCastAndCrew")
        traktManager.getPeopleInShow(showID: "game-of-thrones", extended: [.guestStars]) { result in
            if case .success(let castAndCrew) = result {
                XCTAssertNotNil(castAndCrew.cast)
                XCTAssertNotNil(castAndCrew.guestStars)
                XCTAssertNotNil(castAndCrew.producers)
                XCTAssertEqual(castAndCrew.cast!.count, 43)
                XCTAssertEqual(castAndCrew.producers!.count, 24)
                XCTAssertEqual(castAndCrew.guestStars!.count, 24)
            }
            expectation.fulfill()
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

    func test_get_show_ratings() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/ratings", result: .success(jsonData(named: "test_get_show_ratings")))

        let expectation = XCTestExpectation(description: "Get show ratings")
        traktManager.getShowRatings(showID: "game-of-thrones") { result in
            if case .success(let ratings) = result {
                XCTAssertEqual(ratings.rating, 9.38363)
                XCTAssertEqual(ratings.votes, 51065)
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

    // MARK: - Related

    func test_get_related_shows() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/related?extended=min", result: .success(jsonData(named: "test_get_related_shows")))

        let expectation = XCTestExpectation(description: "Get related shows")
        traktManager.getRelatedShows(showID: "game-of-thrones") { result in
            if case .success(let relatedShows) = result {
                XCTAssertEqual(relatedShows.count, 10)
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

    func test_get_stats() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/stats", result: .success(jsonData(named: "ShowStats")))

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
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watching

    func test_get_users_watching_show() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/watching", result: .success(jsonData(named: "test_get_users_watching_show")))

        let expectation = XCTestExpectation(description: "Get users watching the show")
        traktManager.getUsersWatchingShow(showID: "game-of-thrones") { result in
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

    // MARK: - Next episode

    func test_get_nextEpisode() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/next_episode?extended=min", result: .success(.init()), httpCode: 204)

        let expectation = XCTestExpectation(description: "NextEpisode")
        traktManager.getNextEpisode(showID: "game-of-thrones") { result in
            if case .error(let error) = result {
                XCTAssertNotNil(error)
                do {
                    let traktError = try XCTUnwrap(error as? TraktManager.TraktError)
                    XCTAssertEqual(traktError, TraktManager.TraktError.noContent)
                    expectation.fulfill()
                } catch {
                    XCTFail(error.localizedDescription)
                }
            } else { XCTFail("Unexpected result") }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Last episode

    func test_get_lastEpisode() throws {
        try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/last_episode?extended=min", result: .success(jsonData(named: "LastEpisodeAired_min")))

        let expectation = XCTestExpectation(description: "LastEpisode")
        traktManager.getLastEpisode(showID: "game-of-thrones") { result in
            if case .success(let episode) = result {
                XCTAssertEqual(episode.title, "The Dragon and the Wolf")
                XCTAssertEqual(episode.season, 7)
                XCTAssertEqual(episode.number, 7)
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

}
