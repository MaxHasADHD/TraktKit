//
//  MockTraktCastAndCrewTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/4/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class MockTraktCastAndCrewTests: XCTestCase {
    func testMockCastAndCrew() {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)

        do {
            let personId = ID(trakt: 12345, slug: "12345", tvdb: nil, imdb: nil, tmdb: nil, tvRage: nil)
            let mockPerson = try Person.createMock(
                name: "Michael Cera",
                ids: personId,
                decoder: jsonDecoder)

            let mockCastMember = try CastMember.createMock(
                character: "Scott Pilgrim",
                person: mockPerson,
                decoder: jsonDecoder)

            let mockCastAndCrew = try CastAndCrew.createMock(cast: [mockCastMember], decoder: jsonDecoder)

            XCTAssertEqual(mockCastAndCrew.cast?.count, 1)
            XCTAssertNil(mockCastAndCrew.directors)
            XCTAssertNil(mockCastAndCrew.writers)
            XCTAssertNil(mockCastAndCrew.producers)
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
