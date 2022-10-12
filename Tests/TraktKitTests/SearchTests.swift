//
//  SearchTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/29/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class SearchTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Text query

    func test_search_query() {
        session.nextData = jsonData(named: "test_search_query")

        let expectation = XCTestExpectation(description: "Search")
        traktManager.search(query: "tron", types: [.movie, .show, .episode, .person, .list]) { result in
            if case .success(let searchResults) = result {
                XCTAssertEqual(searchResults.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.path, "/search/movie,show,episode,person,list")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - ID Lookup

    func test_id_lookup() {
        session.nextData = jsonData(named: "test_id_lookup")

        let expectation = XCTestExpectation(description: "Lookup Id")
        traktManager.lookup(id: .IMDB(id: "tt0848228"), type: .movie) { result in
            if case .success(let lookupResults) = result {
                XCTAssertEqual(lookupResults.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.path, "/search/imdb/tt0848228")
        XCTAssertTrue(session.lastURL?.query?.contains("type=movie") ?? false)
        XCTAssertTrue(session.lastURL?.query?.contains("extended=min") ?? false)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
