//
//  UserTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class UserTests: XCTestCase {
    func testParseUserCollectionJSON() {
        let bundle = Bundle(for: UserTests.self)
        let path = bundle.path(forResource: "Collection", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode([UsersCollection].self, from: data)
            
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse playback progress")
        }
    }
}
