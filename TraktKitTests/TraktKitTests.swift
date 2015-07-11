//
//  TraktKitTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import UIKit
import XCTest
@testable import TraktKit

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
                            
                            TraktManager.sharedManager.getShowSummary(traktID, extended: extendedType.Full) { (dictionary, error) -> Void in
                                count++
                                
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
                                
                                if let title = showTitle, _ = showRuntime, _ = showOverview, _ = showNetwork, _ = showStatus, _ = showYear {
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
        
        self.waitForExpectationsWithTimeout(30.0, handler: { (error) -> Void in
            if let error = error {
                print("Timeout error: \(error)")
            }
        })
    }
    
    func testEpisodeRatings() {
        let expectation = self.expectationWithDescription("High Expectations")
        
        TraktManager.sharedManager.getEpisodeRatings(77686, seasonNumber: 1, episodeNumber: 1) { (dictionary, error) -> Void in
            guard error == nil else {
                XCTAssert(false, "Error getting episode ratings")
                return
            }
            
            XCTAssert(true, "Passed!")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { (error) -> Void in
            if let error = error {
                print("Timeout error: \(error)")
            }
        }
    }
    
    func testKeychain() {
        let key = "XCTest"
        let value = "Top Secret"
        
        // Save data
        let savedToKeychain = MLKeychain.setString(value, forKey: key)
        XCTAssert(savedToKeychain, "Item did not save to keychain successfully")
        
        // Load data
        if let data = MLKeychain.loadData(forKey: key) {
            if let stringForm = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                print("Found this in the keychain: \(stringForm)")
                XCTAssert(value == stringForm, "Data should be exact")
            }
            else {
                XCTAssert(false, "Data is not a string")
            }
        }
        else {
            XCTAssert(false, "Keychain did not create data")
        }
        
        // Delete data
        let deletedFromKeychain = MLKeychain.deleteItem(forKey: key)
        XCTAssert(deletedFromKeychain, "Data should be deleted from keychain")
        
        // Re-check data in keychain
        let data = MLKeychain.loadData(forKey: key)
        XCTAssert(data == nil, "Item should not be in the keychain anymore")
    }
}
