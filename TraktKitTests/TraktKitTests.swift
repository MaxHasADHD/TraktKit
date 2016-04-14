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
        TraktManager.sharedManager.setClientID("", clientSecret: "", redirectURI: "") // Fill in to test
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetShow() {
        let expectation = self.expectationWithDescription("High Expectations")
        
        TraktManager.sharedManager.getSeasons(showID: "breaking-bad", extended: .FullAndEpisodes) {
            (seasons, error) in
            guard error == nil else { return }
        
            for season in seasons {
                print("Season \(season.number) has \(season.episodeCount) episodes, which \(season.airedEpisodes) have aired")
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30.0, handler: { (error) -> Void in
            if let error = error {
                print("Timeout error: \(error)")
            }
        })
        
        
    }
}
