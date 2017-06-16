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
    func testParseMinMovieJSON() {
        let bundle = Bundle(for: MovieTests.self)
        let path = bundle.path(forResource: "Movie_Min", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let show = try decoder.decode(TraktMovie.self, from: data)
            XCTAssertEqual(show.title, "TRON: Legacy")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Trakt Movie")
        }
    }
    
    func testParseFullMovieJSON() {
        let bundle = Bundle(for: MovieTests.self)
        let path = bundle.path(forResource: "Movie_Full", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let movie = try decoder.decode(TraktMovie.self, from: data)
            XCTAssertEqual(movie.title, "TRON: Legacy")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Trakt Movie")
        }
    }
}
