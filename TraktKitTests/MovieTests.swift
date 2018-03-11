//
//  MovieTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class MovieTests: XCTestCase {

    func test_get_min_movie() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Movie_Min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "MovieSummary")
        traktManager.getMovieSummary(movieID: "tron-legacy-2010") { result in
            if case .success(let movie) = result {
                XCTAssertEqual(movie.title, "TRON: Legacy")
                XCTAssertEqual(movie.year, 2010)
                XCTAssertEqual(movie.ids.trakt, 1)
                XCTAssertEqual(movie.ids.slug, "tron-legacy-2010")
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_movie() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Movie_Full")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "MovieSummary")
        traktManager.getMovieSummary(movieID: "tron-legacy-2010", extended: [.Full]) { result in
            if case .success(let movie) = result {
                XCTAssertEqual(movie.title, "TRON: Legacy")
                XCTAssertEqual(movie.year, 2010)
                XCTAssertEqual(movie.ids.trakt, 343)
                XCTAssertEqual(movie.ids.slug, "tron-legacy-2010")
                XCTAssertEqual(movie.tagline, "The Game Has Changed.")
                XCTAssertNotNil(movie.overview)
                XCTAssertNotNil(movie.released)
                XCTAssertEqual(movie.runtime, 125)
                XCTAssertNotNil(movie.updatedAt)
                XCTAssertNil(movie.trailer)
                XCTAssertEqual(movie.homepage?.absoluteString, "http://disney.go.com/tron/")
                XCTAssertEqual(movie.language, "en")
                XCTAssertEqual(movie.availableTranslations!, ["en"])
                XCTAssertEqual(movie.genres!, ["action"])
                XCTAssertEqual(movie.certification, "PG-13")
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func testParseMovieReleases() {
        decode("MovieReleases", to: [TraktMovieRelease].self)
    }
}
