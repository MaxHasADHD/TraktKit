//
//  TraktKitTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import UIKit
import XCTest
import TraktKit

class TraktKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseShow() {
        let expectation = self.expectationWithDescription("High Expectations")
        let numberOfTrendingShows = 100
        var count = 0
        
        TraktManager.sharedManager.trendingShows(page: 1, limit: numberOfTrendingShows) { (objects, error) -> Void in
            if let error = error {
                println("Error getting trending shows: \(error)")
                XCTAssert(false, "Error getting trending shows")
            }
            else if let trendingShows = objects {

                for trendingObject in trendingShows {
                    if let showDict = trendingObject["show"] as? [String: AnyObject] {
                        if let showIDs = showDict["ids"] as? [String: AnyObject] {
                            if let traktID = showIDs["trakt"] as? NSNumber {
                                
                                TraktManager.sharedManager.getShowSummary(traktID, extended: extendedType.Full) { (dictionary, error) -> Void in
                                    count++
                                    if let error = error {
                                        println("Error getting Show Summary: \(error)")
                                        XCTAssert(false, "Error getting show summary")
                                    }
                                    else if let summary = dictionary {
                                        let showTitle = summary["title"] as? String
                                        let showCertification = summary["certification"] as? String ?? "Unknown"
                                        let showRuntime = summary["runtime"] as? NSNumber
                                        let showOverview = summary["overview"] as? String
                                        let showCountry = summary["country"] as? String ?? "us"
                                        let showNetwork = summary["network"] as? String
                                        let showStatus = summary["status"] as? String
                                        let showYear = summary["year"] as? NSNumber
                                        let showLanguage = summary["language"] as? String ?? "en"
                                        
                                        if let title = showTitle, runtime = showRuntime, overview = showOverview, network = showNetwork, status = showStatus, year = showYear {
                                            println("Parsed \(title) succesfully!")
                                            XCTAssert(true, "JSON was parsed correctly")
                                        }
                                        else {
                                            println("JSON: \(summary)")
                                            XCTAssert(false, "JSON was not parsed correctly")
                                        }
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
        }
        
        self.waitForExpectationsWithTimeout(30.0, handler: { (error) -> Void in
            if let error = error {
                println("Timeout error: \(error)")
            }
        })
    }
}
