//
//  ListsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/26/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class ListsTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    func test_get_trending_lists() {
        session.nextData = jsonData(named: "test_get_trending_lists")

        let expectation = XCTestExpectation(description: "Get trending lists")
        traktManager.getTrendingLists { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/lists/trending")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_popular_lists() {
        session.nextData = jsonData(named: "test_get_popular_lists")

        let expectation = XCTestExpectation(description: "Get popular lists")
        traktManager.getPopularLists { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/lists/popular")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
}
