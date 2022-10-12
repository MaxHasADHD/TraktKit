//
//  ScrobbleTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/29/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class ScrobbleTests: XCTestCase {
    
    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Start

    func test_start_watching_in_media_center() {
        session.nextData = jsonData(named: "test_start_watching_in_media_center")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated
        
        let expectation = XCTestExpectation(description: "Start watching in media center")
        let scrobble = TraktScrobble(movie: SyncId(trakt: 12345), progress: 1.25)
        try! traktManager.scrobbleStart(scrobble) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response.action, "start")
                XCTAssertEqual(response.progress, 1.25)
                XCTAssertNotNil(response.movie)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/scrobble/start")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Pause

    func test_pause_watching_in_media_center() {
        session.nextData = jsonData(named: "test_pause_watching_in_media_center")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated

        let expectation = XCTestExpectation(description: "Pause watching in media center")
        let scrobble = TraktScrobble(movie: SyncId(trakt: 12345), progress: 75)
        try! traktManager.scrobblePause(scrobble) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response.action, "pause")
                XCTAssertEqual(response.progress, 75)
                XCTAssertNotNil(response.movie)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/scrobble/pause")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Stop

    func test_stop_watching_in_media_center() {
        session.nextData = jsonData(named: "test_stop_watching_in_media_center")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated

        let expectation = XCTestExpectation(description: "Stop watching in media center")
        let scrobble = TraktScrobble(movie: SyncId(trakt: 12345), progress: 99.9)
        try! traktManager.scrobbleStop(scrobble) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response.action, "scrobble")
                XCTAssertEqual(response.progress, 99.9)
                XCTAssertNotNil(response.movie)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/scrobble/stop")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
