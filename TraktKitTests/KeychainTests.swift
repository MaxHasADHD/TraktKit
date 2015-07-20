//
//  KeychainTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/20/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import XCTest
@testable import TraktKit

class KeychainTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
