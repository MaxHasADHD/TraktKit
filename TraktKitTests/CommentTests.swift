//
//  CommentTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class CommentTests: XCTestCase {
    func testParseMinEpisode() {
        guard let comment = decode("Comment", to: Comment.self) else { return }
        XCTAssertEqual(comment.comment, "Agreed, this show is awesome. AMC in general has awesome shows.")
    }
}
