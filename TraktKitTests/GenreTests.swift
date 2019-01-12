//
//  GenreTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/24/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class GenreTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    func test_get_genres() {
        session.nextData = jsonData(named: "test_get_genres")

        let expectation = XCTestExpectation(description: "Get movie genres")
        traktManager.listGenres(type: .Movies) { result in
            if case .success(let genres) = result {
                XCTAssertEqual(genres.count, 33)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/genres/movies")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
