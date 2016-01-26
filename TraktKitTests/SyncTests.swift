//
//  SyncTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/25/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class SyncTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        TraktManager.sharedManager.setClientID("", clientSecret: "", redirectURI: "") // Fill in to test
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
