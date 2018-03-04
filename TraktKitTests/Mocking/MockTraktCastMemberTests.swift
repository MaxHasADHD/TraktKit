//
//  MockTraktCastMemberTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/4/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class MockTraktCastMemberTests: XCTestCase {
    func testMockCastMember() {
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

            XCTAssertEqual(mockCastMember.character, "Scott Pilgrim")
            XCTAssertEqual(mockCastMember.person?.name, "Michael Cera")
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
