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
    
    func testParseSettingsJSON() {
        let data = jsonData(named: "Settings")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode(AccountSettings.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse settings")
        }
    }
    
    func testParseFollowRequest() {
        let data = jsonData(named: "FollowRequest")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode([FollowRequest].self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse follow request")
        }
    }
    
    func testParseHiddenItems() {
        let data = jsonData(named: "HiddenItems")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode([HiddenItem].self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse follow request")
        }
    }
    
    func testUserProfileMinJSON() {
        let data = jsonData(named: "UserProfile_Min")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode(User.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse follow request")
        }
    }
    
    func testUserProfileFullJSON() {
        let data = jsonData(named: "UserProfile_Full")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode(User.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse follow request")
        }
    }
    
    func testUserProfileVIPJSON() {
        let data = jsonData(named: "UserProfile_VIP")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode(User.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse follow request")
        }
    }
    
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
    
    func testParseUserStatsJSON() {
        let data = jsonData(named: "Stats")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode(UserStats.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse user statistics")
        }
    }
    
    func testParseUserWatchlist() {
        let data = jsonData(named: "Watchlist")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode([TraktListItem].self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse user watchlist")
        }
    }
    
    func testParseUserWatched() {
        let data = jsonData(named: "Watched")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let _ = try decoder.decode([TraktWatchedShow].self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse user watchlist")
        }
    }
    
    func testParseUserUnhideItem() {
        let data = jsonData(named: "UnhideItemResult")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            let result = try decoder.decode(UnhideItemResult.self, from: data)
            XCTAssertEqual(result.deleted.movies, 1)
            XCTAssertEqual(result.deleted.shows, 2)
            XCTAssertEqual(result.deleted.seasons, 2)
            XCTAssertEqual(result.notFound.movies.first?.imdb, "tt0000111")
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse unhide item result")
        }
    }
}
