//
//  ShowsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class ShowsTests: XCTestCase {
    func testParseMinShow() {
        guard let show = decode("Show_Min", to: TraktShow.self) else { return }
        XCTAssertEqual(show.title, "Game of Thrones")
    }
    
    func testParseFullShow() {
        guard let show = decode("Show_Full", to: TraktShow.self) else { return }
        XCTAssertEqual(show.title, "Game of Thrones")
    }
    
    func testParseShowCollectionProgress() {
        guard let collectionProgress = decode("ShowCollectionProgress", to: ShowCollectionProgress.self) else { return }
        XCTAssertEqual(collectionProgress.aired, 8)
        XCTAssertEqual(collectionProgress.completed, 6)
        XCTAssertEqual(collectionProgress.seasons.count, 1)

        let season = collectionProgress.seasons[0]
        XCTAssertEqual(season.number, 1)
        XCTAssertEqual(season.aired, 8)
        XCTAssertEqual(season.completed, 6)
    }
    
    func testParseTrendingShows() {
        decode("TrendingShows", to: [TraktShow].self)
    }

    func testParseCastAndCrew() {
        guard let castAndCrew = decode("ShowCastAndCrew_Min", to: CastAndCrew.self) else { return }
        XCTAssertEqual(castAndCrew.cast!.count, 27)
        XCTAssertEqual(castAndCrew.producers!.count, 15)
    }
}
