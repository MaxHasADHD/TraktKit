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
    func testParseMinEpisode() {
        guard let episode = decode("Episode_Min", to: TraktEpisode.self) else { return }
        XCTAssertEqual(episode.title, "Winter Is Coming")
    }
    
    func testParseFullEpisode() {
        guard let episode = decode("Episode_Full", to: TraktEpisode.self) else { return }
        XCTAssertEqual(episode.title, "Winter Is Coming")
    }
}
