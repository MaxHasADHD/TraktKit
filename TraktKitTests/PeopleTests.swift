//
//  PeopleTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class PeopleTests: XCTestCase {
    func testParseMovieCreditsJSON() {
        let bundle = Bundle(for: PeopleTests.self)
        let path = bundle.path(forResource: "MovieCredits", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode(CastAndCrew.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse Cast and crew")
        }
    }
}
