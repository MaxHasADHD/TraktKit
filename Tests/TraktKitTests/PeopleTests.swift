//
//  PeopleTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

final class PeopleTests: TraktTestCase {
    // MARK: - Summary

    func test_parse_person_min() throws {
        try mock(.GET, "https://api.trakt.tv/people/bryan-cranston?extended=min", result: .success(jsonData(named: "Person_Min")))

        let expectation = XCTestExpectation(description: "Get minimal details on a person")
        traktManager.getPersonDetails(personID: "bryan-cranston", extended: [.Min]) { result in
            if case .success(let person) = result {
                XCTAssertEqual(person.name, "Bryan Cranston")
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

    func test_parse_person_full() throws {
        try mock(.GET, "https://api.trakt.tv/people/bryan-cranston?extended=full", result: .success(jsonData(named: "Person_Full")))

        let expectation = XCTestExpectation(description: "Get full details on a person")
        traktManager.getPersonDetails(personID: "bryan-cranston", extended: [.Full]) { result in
            if case .success(let person) = result {
                XCTAssertEqual(person.name, "Bryan Cranston")
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

    // MARK: - Movies

    func test_get_movie_credits() throws {
        try mock(.GET, "https://api.trakt.tv/people/bryan-cranston/movies?extended=min", result: .success(jsonData(named: "test_get_movie_credits")))

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
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Shows

    func test_get_show_credits() throws {
        try mock(.GET, "https://api.trakt.tv/people/bryan-cranston/shows?extended=min", result: .success(jsonData(named: "test_get_show_credits")))

        let expectation = XCTestExpectation(description: "Get show credits for person")
        traktManager.getShowCredits(personID: "bryan-cranston", extended: [.Min]) { result in
            if case .success(let showCredits) = result {
                XCTAssertEqual(showCredits.producers?.count, 4)
                XCTAssertEqual(showCredits.cast?.count, 54)
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

    func test_get_lists_containing_this_person() throws {
        try mock(.GET, "https://api.trakt.tv/people/bryan-cranston/lists", result: .success(jsonData(named: "test_get_lists_containing_this_person")))

        let expectation = XCTestExpectation(description: "Get lists containing person")
        traktManager.getListsContainingPerson(personId: "bryan-cranston") { result in
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
}
