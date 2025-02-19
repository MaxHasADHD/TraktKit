//
//  RecommendationsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/29/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

final class RecommendationsTests: TraktTestCase {
    // MARK: - Movies

    func test_get_movie_recommendations() throws {
        try mock(.GET, "https://api.trakt.tv/recommendations/movies", result: .success(jsonData(named: "test_get_movie_recommendations")))

        let expectation = XCTestExpectation(description: "Get movie recommendations")
        traktManager.getRecommendedMovies { result in
            if case .success(let movies) = result {
                XCTAssertEqual(movies.count, 10)
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

    // MARK: - Hide Movie

    func test_hide_movie_recommendation() throws {
        try mock(.POST, "https://api.trakt.tv/recommendations/movies/922", result: .success(.init()))

        let expectation = XCTestExpectation(description: "Hide movie recommendation")
        traktManager.hideRecommendedMovie(movieID: 922) { result in
            if case .success = result {
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

    // MARK: - Shows

    func test_get_show_recommendations() throws {
        try mock(.GET, "https://api.trakt.tv/recommendations/shows", result: .success(jsonData(named: "test_get_show_recommendations")))

        let expectation = XCTestExpectation(description: "Get show recommendations")
        traktManager.getRecommendedShows { result in
            if case .success(let shows) = result {
                XCTAssertEqual(shows.count, 10)
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

    // MARK: - Hide Show

    func test_hide_show_recommendation() throws {
        try mock(.POST, "https://api.trakt.tv/recommendations/shows/922", result: .success(.init()))

        let expectation = XCTestExpectation(description: "Hide show recommendation")
        traktManager.hideRecommendedShow(showID: 922) { result in
            if case .success = result {
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
