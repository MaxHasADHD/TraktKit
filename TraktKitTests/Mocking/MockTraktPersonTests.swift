//
//  MockTraktPersonTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/3/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class MockTraktPersonTests: XCTestCase {
    func testMinMockPerson() {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        let Id = ID(trakt: 12345, slug: "12345", tvdb: nil, imdb: nil, tmdb: nil, tvRage: nil)

        do {
            let mockPerson = try Person.createMock(
                name: "Robert Downey Jr.",
                ids: Id,
                biography: "I am Iron Man",
                birthday: nil,
                death: nil,
                birthplace: "Manhattan NY",
                decoder: jsonDecoder)

            XCTAssertEqual(mockPerson.name, "Robert Downey Jr.")
            XCTAssertEqual(mockPerson.biography, "I am Iron Man")
            XCTAssertEqual(mockPerson.birthplace, "Manhattan NY")
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
