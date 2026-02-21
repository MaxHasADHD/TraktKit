//
//  ListsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/26/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

final class ListsTests: TraktTestCase {
    func test_get_trending_lists() throws {
        try mock(.GET, "https://api.trakt.tv/lists/trending", result: .success(jsonData(named: "test_get_trending_lists")))

        let expectation = XCTestExpectation(description: "Get trending lists")
        traktManager.getTrendingLists { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists.count, 2)
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

    func test_get_popular_lists() throws {
        try mock(.GET, "https://api.trakt.tv/lists/popular", result: .success(jsonData(named: "test_get_popular_lists")))

        let expectation = XCTestExpectation(description: "Get popular lists")
        traktManager.getPopularLists { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists.count, 2)
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
