//
//  MockTraktSeasonTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/3/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class MockTraktSeasonTests: XCTestCase {
    func testMinMockSeason() {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        let Id = SeasonId(trakt: 12345, tvdb: nil, tmdb: nil, tvRage: nil)
        do {
            let mockSeason = try TraktSeason.createMock(season: 4,
                                                        ids: Id,
                                                        episodeCount: 13,
                                                        airedEpisodes: 1,
                                                        title: "Season 4",
                                                        overview: "The final season",
                                                        decoder: jsonDecoder)
            XCTAssertEqual(mockSeason.number, 4)
            XCTAssertEqual(mockSeason.ids.trakt, 12345)
            XCTAssertEqual(mockSeason.episodeCount, 13)
            XCTAssertEqual(mockSeason.airedEpisodes, 1)
            XCTAssertEqual(mockSeason.title, "Season 4")
            XCTAssertEqual(mockSeason.overview, "The final season")
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
