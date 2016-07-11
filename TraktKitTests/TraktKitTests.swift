//
//  TraktKitTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class TraktKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        TraktManager.sharedManager.setClientID(clientID: "", clientSecret: "", redirectURI: "") // Fill in to test
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetShow() {
        let expectation = self.expectation(withDescription: "High Expectations")
        
        TraktManager.sharedManager.getTrendingMovies(page: 0, limit: 0) { (result) in
            expectation.fulfill()
        }
        
        self.waitForExpectations(withTimeout: 30.0, handler: { (error) -> Void in
            if let error = error {
                print("Timeout error: \(error)")
            }
        })
        
        
    }
}
