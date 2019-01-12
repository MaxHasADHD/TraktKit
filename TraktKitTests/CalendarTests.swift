//
//  CalendarTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/23/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class CalendarTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - My Shows

    func test_get_my_shows() {
        session.nextData = jsonData(named: "test_get_my_shows")

        let expectation = XCTestExpectation(description: "My Shows")
        traktManager.myShows(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let myShows) = result {
                XCTAssertEqual(myShows.count, 4)
                expectation.fulfill()
            }
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/my/shows/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - My New Shows

    func test_get_my_new_shows() {
        session.nextData = jsonData(named: "test_get_my_new_shows")

        let expectation = XCTestExpectation(description: "My New Shows")
        traktManager.myNewShows(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let myShows) = result {
                XCTAssertEqual(myShows.count, 1)
                expectation.fulfill()
            }
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/my/shows/new/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - My Season Premiers

    func test_get_my_season_premieres() {
        session.nextData = jsonData(named: "test_get_my_season_premieres")

        let expectation = XCTestExpectation(description: "My New Seasons")
        traktManager.mySeasonPremieres(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let premieres) = result {
                XCTAssertEqual(premieres.count, 2)
                expectation.fulfill()
            }
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/my/shows/premieres/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - My Movies

    func test_get_my_movies() {
        session.nextData = jsonData(named: "test_get_my_movies")

        let expectation = XCTestExpectation(description: "My movies")
        traktManager.myMovies(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let movies) = result {
                XCTAssertEqual(movies.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/my/movies/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - My DVD

    func test_get_my_dvd() {
        session.nextData = jsonData(named: "test_get_my_dvd")

        let expectation = XCTestExpectation(description: "My dvds")
        traktManager.myDVDReleases(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let dvds) = result {
                XCTAssertEqual(dvds.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/my/dvd/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - All Shows

    func test_get_all_shows() {
        session.nextData = jsonData(named: "test_get_all_shows")

        let expectation = XCTestExpectation(description: "All Shows")
        traktManager.allShows(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let allShows) = result {
                XCTAssertEqual(allShows.count, 4)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/all/shows/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - All New Shows

    func test_get_all_new_shows() {
        session.nextData = jsonData(named: "test_get_all_new_shows")

        let expectation = XCTestExpectation(description: "All New Shows")
        traktManager.allNewShows(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let newShows) = result {
                XCTAssertEqual(newShows.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/all/shows/new/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - All Season Premiers

    func test_get_season_premieres() {
        session.nextData = jsonData(named: "test_get_season_premieres")

        let expectation = XCTestExpectation(description: "All Season Premieres")
        traktManager.allSeasonPremieres(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let allPremiers) = result {
                XCTAssertEqual(allPremiers.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/all/shows/premieres/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - All Movies

    func test_get_all_movies() {
        session.nextData = jsonData(named: "test_get_all_movies")

        let expectation = XCTestExpectation(description: "All Movies")
        traktManager.allMovies(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let allMovies) = result {
                XCTAssertEqual(allMovies.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/all/movies/2014-09-01/7?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - All DVD

    func test_get_all_dvd() {
        session.nextData = jsonData(named: "test_get_all_dvd")

        let expectation = XCTestExpectation(description: "All DVDs")
        traktManager.allDVD(startDateString: "2014-09-01", days: 7) { result in
            if case .success(let allDVDs) = result {
                XCTAssertEqual(allDVDs.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/calendars/all/dvd/2014-09-01/7")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
