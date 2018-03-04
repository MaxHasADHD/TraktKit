//
//  MockTraktEpisodeTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/3/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class MockTraktEpisodeTests: XCTestCase {

    func testMinMockEpisode() {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        let Id = EpisodeId(trakt: 12345, tvdb: nil, imdb: nil, tmdb: nil, tvRage: nil)

        do {
            let mockEpisode = try TraktEpisode.createMock(title: "Are You Ready for Some Zombies?",
                                                       season: 4,
                                                       episode: 1,
                                                       ids: Id,
                                                       overview: "While investigating the murder of a Seattle Seahawk superfan, ...",
                                                       rating: nil,
                                                       votes: nil,
                                                       firstAired: nil,
                                                       updatedAt: nil,
                                                       availableTranslations: nil,
                                                       decoder: jsonDecoder)
            XCTAssertEqual(mockEpisode.title, "Are You Ready for Some Zombies?")
            XCTAssertEqual(mockEpisode.season, 4)
            XCTAssertEqual(mockEpisode.number, 1)
            XCTAssertEqual(mockEpisode.overview, "While investigating the murder of a Seattle Seahawk superfan, ...")
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
