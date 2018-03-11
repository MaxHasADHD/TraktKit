//
//  EpisodeTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class EpisodeTests: XCTestCase {

    func test_get_min_episode() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Episode_Min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "EpisodeSummary")
        traktManager.getEpisodeSummary(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1) { result in

            if case .success(let episode) = result {
                XCTAssertEqual(episode.title, "Winter Is Coming")
                XCTAssertEqual(episode.season, 1)
                XCTAssertEqual(episode.number, 1)
                XCTAssertEqual(episode.ids.trakt, 36440)
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_episode() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Episode_Full")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "EpisodeSummary")
        traktManager.getEpisodeSummary(showID: "game-of-thrones", seasonNumber: 1, episodeNumber: 1, extended: [.Full]) { result in

            if case .success(let episode) = result {
                XCTAssertEqual(episode.title, "Winter Is Coming")
                XCTAssertEqual(episode.season, 1)
                XCTAssertEqual(episode.number, 1)
                XCTAssertEqual(episode.ids.trakt, 36440)
                XCTAssertNotNil(episode.overview)
                XCTAssertNotNil(episode.firstAired)
                XCTAssertNotNil(episode.updatedAt)
                XCTAssertEqual(episode.availableTranslations!, ["en"])
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/shows/game-of-thrones/seasons/1/episodes/1?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
