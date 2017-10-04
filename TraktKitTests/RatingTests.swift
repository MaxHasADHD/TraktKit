//
//  RatingTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class RatingTests: XCTestCase {
    func testParseRatings() {
        guard let ratingDistribution = decode("Ratings", to: RatingDistribution.self) else { return }
        XCTAssertEqual(ratingDistribution.rating, 7.33778)
        XCTAssertEqual(ratingDistribution.votes, 7866)
        XCTAssertEqual(ratingDistribution.distribution.one, 298)
        XCTAssertEqual(ratingDistribution.distribution.two, 46)
        XCTAssertEqual(ratingDistribution.distribution.three, 87)
        XCTAssertEqual(ratingDistribution.distribution.four, 178)
        XCTAssertEqual(ratingDistribution.distribution.five, 446)
        XCTAssertEqual(ratingDistribution.distribution.six, 1167)
        XCTAssertEqual(ratingDistribution.distribution.seven, 1855)
        XCTAssertEqual(ratingDistribution.distribution.eight, 1543)
        XCTAssertEqual(ratingDistribution.distribution.nine, 662)
        XCTAssertEqual(ratingDistribution.distribution.ten, 1583)
    }
}
