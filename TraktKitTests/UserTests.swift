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

    func test_get_settings() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Settings")
        let traktManager = TraktManager(session: session)
        traktManager.accessToken = "test"

        let expectation = XCTestExpectation(description: "settings")
        traktManager.getSettings { result in
            if case .success(let accountSessings) = result {
                XCTAssertEqual(accountSessings.user.name, "Justin Nemeth")
                XCTAssertEqual(accountSessings.user.gender, "male")
                XCTAssertEqual(accountSessings.connections.twitter, true)
                XCTAssertEqual(accountSessings.connections.slack, false)
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/users/settings")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_follow_request() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "FollowRequest")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "FollowRequest")
        traktManager.getFollowRequests { result in
            if case .success(let followRequests) = result {
                XCTAssertEqual(followRequests.count, 1)
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/users/requests")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_hidden_items() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "HiddenItems")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "HiddenItems")
        traktManager.hiddenItems(section: .ProgressWatched, type: .Show, page: 1, limit: 10) { result in
            if case .success(let hiddenShows, _, _) = result {
                XCTAssertEqual(hiddenShows.count, 2)
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/users/hidden/progress_watched?page=1&limit=10&type=show&extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_min_profile() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "UserProfile_Min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "User Profile")
        traktManager.getUserProfile { result in
            if case .success(let user) = result {
                XCTAssertEqual(user.username, "sean")
                XCTAssertEqual(user.isPrivate, false)
                XCTAssertEqual(user.isVIP, true)
                XCTAssertEqual(user.isVIPEP, true)
                XCTAssertEqual(user.name, "Sean Rudford")
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/users/me?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_profile() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "UserProfile_Full")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "User Profile")
        traktManager.getUserProfile(extended: [.Full]) { result in
            if case .success(let user) = result {
                XCTAssertEqual(user.username, "sean")
                XCTAssertEqual(user.isPrivate, false)
                XCTAssertEqual(user.isVIP, true)
                XCTAssertEqual(user.isVIPEP, true)
                XCTAssertEqual(user.name, "Sean Rudford")
                XCTAssertNotNil(user.joinedAt)
                XCTAssertEqual(user.age, 35)
                XCTAssertEqual(user.about, "I have all your cassette tapes.")
                XCTAssertEqual(user.location, "SF")
                XCTAssertEqual(user.gender, "male")
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/users/me?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_VIP_profile() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "UserProfile_VIP")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "User Profile")
        traktManager.getUserProfile(extended: [.Full]) { result in
            if case .success(let user) = result {
                XCTAssertEqual(user.username, "sean")
                XCTAssertEqual(user.isPrivate, false)
                XCTAssertEqual(user.isVIP, true)
                XCTAssertEqual(user.isVIPEP, true)
                XCTAssertEqual(user.name, "Sean Rudford")
                XCTAssertEqual(user.vipYears, 5)
                XCTAssertEqual(user.vipOG, true)
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/users/me?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
    
    func test_get_collection() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Collection")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "User Collection")
        traktManager.getUserCollection(type: .Movies) { result in
            if case .success(let collection) = result {
                let movies = collection.map { $0.movie }
                XCTAssertEqual(movies.count, 2)
            } else { XCTFail("Unexpected result") }
            expectation.fulfill()
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/users/me/collection/movies")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
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
