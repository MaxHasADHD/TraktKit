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
    func testParseMinEpisodeJSON() {
        let bundle = Bundle(for: CommentTests.self)
        let path = bundle.path(forResource: "Comment", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let comment = try decoder.decode(Comment.self, from: data)
            XCTAssertEqual(comment.comment, "Agreed, this show is awesome. AMC in general has awesome shows.")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Trakt Comment")
        }
    }
}
