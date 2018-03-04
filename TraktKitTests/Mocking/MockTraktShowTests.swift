//
//  MockTraktShowTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 2/27/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class MockTraktShowTests: XCTestCase {

    func testMinMockShow() {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        let Id = ID(trakt: 12345,
                    slug: "iZombie",
                    tvdb: nil,
                    imdb: nil,
                    tmdb: nil,
                    tvRage: nil)
        do {
            let mockShow = try TraktShow.createMock(title: "iZombie",
                                     year: 2014,
                                     ids: Id,
                                     decoder: jsonDecoder)
            XCTAssertEqual(mockShow.title, "iZombie")
            XCTAssertEqual(mockShow.ids.trakt, 12345)
            XCTAssertEqual(mockShow.ids.slug, "iZombie")
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
