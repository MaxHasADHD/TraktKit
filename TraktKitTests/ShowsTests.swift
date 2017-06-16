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
        let bundle = Bundle(for: ShowsTests.self)
        let path = bundle.path(forResource: "Show_Min", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
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
        let bundle = Bundle(for: ShowsTests.self)
        let path = bundle.path(forResource: "Show_Full", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
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
}
