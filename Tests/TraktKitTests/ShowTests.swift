//
//  ShowTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/20/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit
/*
class ShowTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseShow() {
        let expectation = self.expectation(description: "High Expectations")
        let numberOfTrendingShows = 100
        var count = 0
        
        TraktManager.sharedManager.getTrendingShows(page: 1, limit: numberOfTrendingShows) { (objects, error) -> Void in
            guard error == nil else {
                print("Error getting trending shows: \(error)")
                XCTAssert(false, "Error getting trending shows")
                return
            }
            
            guard let trendingShows = objects else {
                XCTAssert(false, "objects is nil")
                return
            }
            
            for trendingObject in trendingShows {
                if let showDict = trendingObject["show"] as? [String: AnyObject] {
                    if let showIDs = showDict["ids"] as? [String: AnyObject] {
                        if let traktID = showIDs["trakt"] as? NSNumber {
                            
                            TraktManager.sharedManager.getShowSummary(showID: traktID, extended: [ExtendedType.Full]) { (dictionary, error) -> Void in
                                count = count + 1
                                
                                guard error == nil else {
                                    print("Error getting Show Summary: \(error)")
                                    XCTAssert(false, "Error getting show summary")
                                    return
                                }
                                
                                guard let summary = dictionary else {
                                    XCTAssert(false, "Error getting show summary")
                                    return
                                }
                                
                                let showTitle = summary["title"] as? String
                                let _ = summary["certification"] as? String ?? "Unknown"
                                let showRuntime = summary["runtime"] as? NSNumber
                                let showOverview = summary["overview"] as? String
                                let _ = summary["country"] as? String ?? "us"
                                let showNetwork = summary["network"] as? String
                                let showStatus = summary["status"] as? String
                                let showYear = summary["year"] as? NSNumber
                                let _ = summary["language"] as? String ?? "en"
                                
                                if let title = showTitle, let _ = showRuntime, let _ = showOverview, let _ = showNetwork, let _ = showStatus, let _ = showYear {
                                    print("Parsed \(title) succesfully!")
                                    XCTAssert(true, "JSON was parsed correctly")
                                }
                                else {
                                    print("JSON: \(summary)")
                                    XCTAssert(false, "JSON was not parsed correctly")
                                }
                                
                                if count == numberOfTrendingShows {
                                    expectation.fulfill()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.waitForExpectations(timeout: 30.0, handler: { (error) -> Void in
            if let error = error {
                print("Timeout error: \(error)")
            }
        })
    }
    
    func testEpisodeRatings() {
        let expectation = self.expectation(description: "High Expectations")
        
        TraktManager.sharedManager.getEpisodeRatings(showID: 77686, seasonNumber: 1, episodeNumber: 1) { (dictionary, error) -> Void in
            guard error == nil else {
                XCTAssert(false, "Error getting episode ratings")
                return
            }
            
            XCTAssert(true, "Passed!")
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) -> Void in
            if let error = error {
                print("Timeout error: \(error)")
            }
        }
    }
}*/
