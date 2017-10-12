//
//  PeopleTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class PeopleTests: XCTestCase {
    func testParsePersonMin() {
        decode("Person_Min", to: Person.self)
    }

    func testParsePersonFull() {
        decode("Person_Full", to: Person.self)
    }

    func testParseMovieCredits() {
        decode("MovieCredits", to: CastAndCrew.self)
    }
}
