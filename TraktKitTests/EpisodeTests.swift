//
//  EpisodeTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class EpisodeTests: XCTestCase {
    func testParseMinEpisodeJSON() {
        let bundle = Bundle(for: EpisodeTests.self)
        let path = bundle.path(forResource: "Episode_Min", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        do {
            let episode = try decoder.decode(TraktEpisode.self, from: data)
            XCTAssertEqual(episode.title, "Winter Is Coming")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Trakt Show")
        }
    }
    
    func testParseFullEpisodeJSON() {
        let bundle = Bundle(for: EpisodeTests.self)
        let path = bundle.path(forResource: "Episode_Full", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let episode = try decoder.decode(TraktEpisode.self, from: data)
            XCTAssertEqual(episode.title, "Winter Is Coming")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Trakt Show")
        }
    }
}
