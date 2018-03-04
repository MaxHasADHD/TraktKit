//
//  MockTraktCrewMemberTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/4/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class MockTraktCrewMemberTests: XCTestCase {
    func testMockCrewMember() {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)

        do {
            let personId = ID(trakt: 12345, slug: "12345", tvdb: nil, imdb: nil, tmdb: nil, tvRage: nil)
            let mockPerson = try Person.createMock(
                name: "Joss Whedon",
                ids: personId,
                decoder: jsonDecoder)

            let mockCrewMember = try CrewMember.createMock(
                job: "Director",
                person: mockPerson,
                decoder: jsonDecoder)

            XCTAssertEqual(mockCrewMember.job, "Director")
            XCTAssertEqual(mockCrewMember.person?.name, "Joss Whedon")
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
