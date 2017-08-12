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
    func testParseMinShowJSON() {
        let data = jsonData(named: "Show_Min")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let show = try decoder.decode(TraktShow.self, from: data)
            XCTAssertEqual(show.title, "Game of Thrones")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Trakt Show")
        }
    }
    
    func testParseFullShowJSON() {
        let data = jsonData(named: "Show_Full")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let show = try decoder.decode(TraktShow.self, from: data)
            XCTAssertEqual(show.title, "Game of Thrones")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Trakt Show")
        }
    }
    
    func testParseShowCollectionProgress() {
        let data = jsonData(named: "ShowCollectionProgress")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let collectionProgress = try decoder.decode(ShowCollectionProgress.self, from: data)
            XCTAssertEqual(collectionProgress.aired, 8)
            XCTAssertEqual(collectionProgress.completed, 6)
            XCTAssertEqual(collectionProgress.seasons.count, 1)
            
            let season = collectionProgress.seasons[0]
            XCTAssertEqual(season.number, 1)
            XCTAssertEqual(season.aired, 8)
            XCTAssertEqual(season.completed, 6)
            
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse show collection progress")
        }
    }
    
    func testParseTrendingShows() {
        let data = jsonData(named: "TrendingShows")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode([TraktShow].self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse trending shows")
        }
    }

    func testParseCastAndCrew() {
        let data = jsonData(named: "ShowCastAndCrew_Min")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let castAndCrew = try decoder.decode(CastAndCrew.self, from: data)
            
            XCTAssertEqual(castAndCrew.cast!.count, 27)
            XCTAssertEqual(castAndCrew.producers!.count, 15)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse cast and crew")
        }
    }
    
}
