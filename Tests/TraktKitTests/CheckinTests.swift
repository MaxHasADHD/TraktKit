//
//  CheckinTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/24/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

final class CheckinTests: TraktTestCase {

    func test_checkin_movie() throws {
        try mock(.POST, "https://api.trakt.tv/checkin", result: .success(jsonData(named: "test_checkin_movie")))

        let expectation = XCTestExpectation(description: "Checkin a movie")
        let checkin = TraktCheckinBody(movie: SyncId(trakt: 12345))
        traktManager.checkIn(checkin) { result in
            if case .success(let checkin) = result {
                XCTAssertEqual(checkin.id, 3373536619)
                XCTAssertNotNil(checkin.movie)
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

    func test_checkin_episode() throws {
        try mock(.POST, "https://api.trakt.tv/checkin", result: .success(jsonData(named: "test_checkin_episode")))

        let expectation = XCTestExpectation(description: "Checkin a episode")
        let checkin = TraktCheckinBody(episode: SyncId(trakt: 12345))
        traktManager.checkIn(checkin) { result in
            if case .success(let checkin) = result {
                XCTAssertEqual(checkin.id, 3373536620)
                XCTAssertNotNil(checkin.episode)
                XCTAssertNotNil(checkin.show)
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

    func test_already_checked_in() throws {
        try mock(.POST, "https://api.trakt.tv/checkin", result: .success(jsonData(named: "test_already_checked_in")), httpCode: StatusCodes.Conflict)

        let expectation = XCTestExpectation(description: "Checkin an existing item")
        let checkin = TraktCheckinBody(episode: SyncId(trakt: 12345))
        traktManager.checkIn(checkin) { result in
            if case .checkedIn(let expiration) = result {
                XCTAssertEqual(expiration.dateString(withFormat: "YYYY-MM-dd"), "2014-10-15")
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

    func test_delete_active_checkins() throws {
        try mock(.POST, "https://api.trakt.tv/checkin", result: .success(jsonData(named: "test_already_checked_in")), httpCode: StatusCodes.SuccessNoContentToReturn)

        let expectation = XCTestExpectation(description: "Delete active checkins")
        traktManager.deleteActiveCheckins { result in
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
