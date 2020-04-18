//
//  PeopleTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class PeopleTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Summary

    func testParsePersonMin() {
        session.nextData = jsonData(named: "Person_Min")

        let expectation = XCTestExpectation(description: "Get minimal details on a person")
        traktManager.getPersonDetails(personID: "bryan-cranston", extended: [.Min]) { result in
            if case .success(let person) = result {
                XCTAssertEqual(person.name, "Bryan Cranston")
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/people/bryan-cranston?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func testParsePersonFull() {
        session.nextData = jsonData(named: "Person_Full")

        let expectation = XCTestExpectation(description: "Get full details on a person")
        traktManager.getPersonDetails(personID: "bryan-cranston", extended: [.Full]) { result in
            if case .success(let person) = result {
                XCTAssertEqual(person.name, "Bryan Cranston")
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/people/bryan-cranston?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }

    }

    // MARK: - Movies

    func test_get_movie_credits() {
        session.nextData = jsonData(named: "test_get_movie_credits")

        let expectation = XCTestExpectation(description: "Get movie credits for person")
        traktManager.getMovieCredits(personID: "bryan-cranston", extended: [.Min]) { result in
            if case .success(let movieCredits) = result {
                XCTAssertEqual(movieCredits.writers?.count, 2)
                XCTAssertEqual(movieCredits.directors?.count, 1)
                XCTAssertEqual(movieCredits.cast?.count, 69)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/people/bryan-cranston/movies?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Shows

    func test_get_show_credits() {
        session.nextData = jsonData(named: "test_get_show_credits")

        let expectation = XCTestExpectation(description: "Get show credits for person")
        traktManager.getShowCredits(personID: "bryan-cranston", extended: [.Min]) { result in
            if case .success(let showCredits) = result {
                XCTAssertEqual(showCredits.producers?.count, 4)
                XCTAssertEqual(showCredits.cast?.count, 54)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/people/bryan-cranston/shows?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_lists_containing_this_person() {
        session.nextData = jsonData(named: "test_get_lists_containing_this_person")

        let expectation = XCTestExpectation(description: "Get lists containing person")
        traktManager.getListsContainingPerson(personId: "bryan-cranston") { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/people/bryan-cranston/lists")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
