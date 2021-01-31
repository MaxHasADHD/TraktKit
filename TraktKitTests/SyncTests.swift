//
//  SyncTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class SyncTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Last Activities

    func test_get_last_activity() {
        session.nextData = jsonData(named: "test_get_last_activity")

        let expectation = XCTestExpectation(description: "Get Last Activity")
        traktManager.lastActivities { result in
            if case .success(_) = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/last_activities")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Playback

    func test_get_playback_progress() {
        session.nextData = jsonData(named: "test_get_playback_progress")

        let expectation = XCTestExpectation(description: "Get Playback progress")
        traktManager.getPlaybackProgress(type: .Movies) { result in
            if case .success(let progress) = result {
                XCTAssertEqual(progress.count, 2)
                let first = progress.first
                XCTAssertEqual(first?.progress, 10)
                XCTAssertNotNil(first?.movie)
                XCTAssertEqual(first?.id, 13)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/playback/movies")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Remove Playback

    func test_remove_a_playback_item() {
        session.nextStatusCode = StatusCodes.SuccessNoContentToReturn

        let expectation = XCTestExpectation(description: "Remove playback item")
        traktManager.removePlaybackItem(id: 13) { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/playback/13")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Get Collection

    func test_get_collection() {
        session.nextData = jsonData(named: "test_get_collection")

        let expectation = XCTestExpectation(description: "Get collection")
        traktManager.getCollection(type: .Movies) { result in
            if case .success(let collection) = result {
                XCTAssertEqual(collection.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/collection/movies?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func test_get_collection_shows() {
        session.nextData = jsonData(named: "test_get_collection_shows")
        
        let expectation = XCTestExpectation(description: "Get shows collection")
        traktManager.getCollection(type: .Shows) { result in
            if case .success(let collection) = result {
                XCTAssertEqual(collection.count, 2)
                collection.forEach {
                    XCTAssertNotNil($0.lastCollectedAt)
                    XCTAssertNotNil($0.lastUpdatedAt)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/collection/shows?extended=min")
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Add to Collection

    func test_add_items_to_collection() {
        session.nextData = jsonData(named: "test_add_items_to_collection")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated

        let expectation = XCTestExpectation(description: "Add items to collection")
        try! traktManager.addToCollection(movies: [], shows: [], episodes: []) { result in
            if case .success(let result) = result {
                XCTAssertEqual(result.added.movies, 1)
                XCTAssertEqual(result.added.episodes, 12)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/collection")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Remove from Collection

    func test_remove_items_from_collection() {
        session.nextData = jsonData(named: "test_remove_items_from_collection")

        let expectation = XCTestExpectation(description: "Remove items from collection")
        try! traktManager.removeFromCollection(movies: [], shows: [], episodes: []) { result in
            if case .success(let result) = result {
                XCTAssertEqual(result.deleted.movies, 1)
                XCTAssertEqual(result.deleted.episodes, 12)
                XCTAssertEqual(result.notFound.episodes.count, 0)
                XCTAssertEqual(result.notFound.movies.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/collection/remove")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Get Watched

    func test_get_watched() {
        session.nextData = jsonData(named: "test_get_watched")

        let expectation = XCTestExpectation(description: "Get Watched")
        traktManager.getWatchedMovies { result in
            if case .success(let watchedMovies, _, _) = result {
                XCTAssertEqual(watchedMovies.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/watched/movies?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func test_get_watched_shows_noseasons() {
        session.nextData = jsonData(named: "test_get_watched_shows_noseasons")
        
        let expectation = XCTestExpectation(description: "Get Watched - noSeasons")
        traktManager.getWatchedShows(extended: [.noSeasons]) { result in
            if case .success(let watchedShows) = result {
                XCTAssertEqual(watchedShows.count, 2)
                watchedShows.forEach {
                    XCTAssertNotNil($0.lastWatchedAt)
                    XCTAssertNotNil($0.lastUpdatedAt)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/watched/shows?extended=noseasons")
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func test_get_watched_shows() {
        session.nextData = jsonData(named: "test_get_watched_shows")
        
        let expectation = XCTestExpectation(description: "Get Watched")
        traktManager.getWatchedShows { result in
            if case .success(let watchedShows) = result {
                XCTAssertEqual(watchedShows.count, 2)
                watchedShows.forEach {
                    XCTAssertNotNil($0.lastWatchedAt)
                    XCTAssertNotNil($0.lastUpdatedAt)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/watched/shows?extended=min")
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Get History

    func test_get_watched_history() {
        session.nextData = jsonData(named: "test_get_watched_history")

        let expectation = XCTestExpectation(description: "Get Watched history")
        traktManager.getHistory(type: .Movies) { result in
            if case .success(let history, _, _) = result {
                XCTAssertEqual(history.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/history/movies?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Add to History

    func test_add_items_to_watched_history() {
        session.nextData = jsonData(named: "test_add_items_to_watched_history")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated

        let expectation = XCTestExpectation(description: "Add items to history")
        try! traktManager.addToHistory(movies: [], shows: [], episodes: []) { result in
            switch result {
            case .success(let ids):
                XCTAssertEqual(ids.added.movies, 2)
                XCTAssertEqual(ids.added.episodes, 72)
            case .error:
                XCTFail("Wrong status")
            }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/history")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Remove from History

    func test_remove_items_from_history() {
        session.nextData = jsonData(named: "test_remove_items_from_history")

        let expectation = XCTestExpectation(description: "Remove items from history")
        try! traktManager.removeFromHistory(movies: [], shows: [], episodes: []) { result in
            switch result {
            case .success(let ids):
                XCTAssertEqual(ids.deleted.movies, 2)
                XCTAssertEqual(ids.deleted.episodes, 72)
            case .error(let error):
                XCTFail("Wrong status: \(String(describing: error))")
            }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/history/remove")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Get Ratings

    func test_get_ratings() {
        session.nextData = jsonData(named: "test_get_ratings")

        let expectation = XCTestExpectation(description: "Get ratings")
        traktManager.getRatings(type: .Movies, rating: 9) { result in
            if case .success(let ratings) = result {
                XCTAssertEqual(ratings.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/ratings/movies/9")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Add Ratings

    func test_add_new_ratings() {
        session.nextData = jsonData(named: "test_add_new_ratings")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated

        let expectation = XCTestExpectation(description: "Add rating")
        try! traktManager.addRatings(movies: [RatingId(trakt: 12345, rating: 10, ratedAt: Date())]) { result in
            if case .success(let result) = result {
                XCTAssertEqual(result.added.movies, 1)
                XCTAssertEqual(result.added.shows, 1)
                XCTAssertEqual(result.added.seasons, 1)
                XCTAssertEqual(result.added.episodes, 2)
                XCTAssertEqual(result.notFound.movies.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/ratings")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Remove Ratings

    func test_remove_ratings() {
        session.nextData = jsonData(named: "test_remove_ratings")

        let expectation = XCTestExpectation(description: "Remove rating")
        try! traktManager.removeRatings(movies: [], shows: [], episodes: []) { result in
            if case .success(let result) = result {
                XCTAssertEqual(result.deleted.movies, 1)
                XCTAssertEqual(result.deleted.shows, 1)
                XCTAssertEqual(result.deleted.seasons, 1)
                XCTAssertEqual(result.deleted.episodes, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/ratings/remove")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Get Watchlist

    func test_get_watchlist() {
        session.nextData = jsonData(named: "test_get_watchlist")

        let expectation = XCTestExpectation(description: "Get watchlist")
        traktManager.getWatchlist(watchType: .Movies) { result in
            if case .success(let watchlist, _, _) = result {
                XCTAssertEqual(watchlist.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/watchlist/movies?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Add to Watchlist

    func test_add_items_to_watchlist() {
        session.nextData = jsonData(named: "test_add_items_to_watchlist")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated

        let expectation = XCTestExpectation(description: "Add items to watchlist")
        try! traktManager.addToWatchlist(movies: [], shows: [], episodes: []) { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/watchlist")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Remove from Watchlist

    func test_remove_items_from_watchlist() {
        session.nextData = jsonData(named: "test_remove_items_from_watchlist")

        let expectation = XCTestExpectation(description: "Remove items from watchlist")
        try! traktManager.removeFromWatchlist(movies: [], shows: [], episodes: []) { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/sync/watchlist/remove")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
