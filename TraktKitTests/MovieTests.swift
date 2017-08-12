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
        let data = jsonData(named: "Movie_Min")
        
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
        let data = jsonData(named: "Movie_Full")
        
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
    
    func testParseMovieReleases() {
        let data = jsonData(named: "MovieReleases")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode([TraktMovieRelease].self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse movie releases")
        }
    }
}
