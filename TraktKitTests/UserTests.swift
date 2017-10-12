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
    func testParseSettings() {
        decode("Settings", to: AccountSettings.self)
    }
    
    func testParseFollowRequest() {
        decode("FollowRequest", to: [FollowRequest].self)
    }
    
    func testParseHiddenItems() {
        decode("HiddenItems", to: [HiddenItem].self)
    }
    
    func testUserProfileMin() {
        decode("UserProfile_Min", to: User.self)
    }
    
    func testUserProfileFull() {
        decode("UserProfile_Full", to: User.self)
    }
    
    func testUserProfileVIP() {
        decode("UserProfile_VIP", to: User.self)
    }
    
    func testParseUserCollection() {
        decode("Collection", to: [UsersCollection].self)
    }
    
    func testParseUserStats() {
        decode("Stats", to: UserStats.self)
    }
    
    func testParseUserWatchlist() {
        decode("Watchlist", to: [TraktListItem].self)
    }
    
    func testParseUserWatched() {
        decode("Watched", to: [TraktWatchedShow].self)
    }
    
    func testParseUserUnhideItem() {
        guard let result = decode("UnhideItemResult", to: UnhideItemResult.self) else { return }
        XCTAssertEqual(result.deleted.movies, 1)
        XCTAssertEqual(result.deleted.shows, 2)
        XCTAssertEqual(result.deleted.seasons, 2)
    }

    func testParseUserCreateListResult() {
        decode("CreateListResult", to: TraktList.self)
    }
}
