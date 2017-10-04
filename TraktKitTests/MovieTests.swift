//
//  MovieTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class MovieTests: XCTestCase {
    func testParseMinMovie() {
        guard let movie = decode("Movie_Min", to: TraktMovie.self) else { return }
        XCTAssertEqual(movie.title, "TRON: Legacy")
    }
    
    func testParseFullMovie() {
        guard let movie = decode("Movie_Full", to: TraktMovie.self) else { return }
        XCTAssertEqual(movie.title, "TRON: Legacy")
    }
    
    func testParseMovieReleases() {
        decode("MovieReleases", to: [TraktMovieRelease].self)
    }
}
