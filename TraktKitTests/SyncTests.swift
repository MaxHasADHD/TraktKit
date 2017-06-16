//
//  SyncTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class SyncTests: XCTestCase {
    func testParsePlaybackProgressJSON() {
        let bundle = Bundle(for: SyncTests.self)
        let path = bundle.path(forResource: "PlaybackProgress", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let playbackProgress = try decoder.decode([PlaybackProgress].self, from: data)
            let moviePlaybackProgress = playbackProgress.filter { $0.type == "movie" }.first
            XCTAssertNotNil(moviePlaybackProgress)
            XCTAssertEqual(moviePlaybackProgress?.progress, 10)
            XCTAssertEqual(moviePlaybackProgress?.id, 13)
            XCTAssertNotNil(moviePlaybackProgress?.movie)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse playback progress")
        }
    }
}
