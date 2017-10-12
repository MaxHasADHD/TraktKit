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
    func testParsePlaybackProgress() {
        guard let playbackProgress = decode("PlaybackProgress", to: [PlaybackProgress].self) else { return }
        let moviePlaybackProgress = playbackProgress.filter { $0.type == "movie" }.first
        XCTAssertNotNil(moviePlaybackProgress)
        XCTAssertEqual(moviePlaybackProgress?.progress, 10)
        XCTAssertEqual(moviePlaybackProgress?.id, 13)
        XCTAssertNotNil(moviePlaybackProgress?.movie)
    }
}
