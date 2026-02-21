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

final class UserTests: TraktTestCase {

    // MARK: - Settings

    func test_get_settings() async throws {
        try mock(.GET, "https://api.trakt.tv/users/settings", result: .success(jsonData(named: "test_get_settings")))

        let settings = try await traktManager.currentUser().settings().perform()
        XCTAssertEqual(settings.user.name, "Justin Nemeth")
        XCTAssertEqual(settings.user.gender, "male")
        XCTAssertEqual(settings.connections.twitter, true)
        XCTAssertEqual(settings.connections.slack, false)
        XCTAssertEqual(settings.limits.list.count, 2)
        XCTAssertEqual(settings.limits.list.itemCount, 100)
    }

    // MARK: - Follower requests

    func test_get_follow_request() throws {
        try mock(.GET, "https://api.trakt.tv/users/requests", result: .success(jsonData(named: "test_get_follow_request")))

        let expectation = XCTestExpectation(description: "FollowRequest")
        traktManager.getFollowRequests { result in
            if case .success(let followRequests) = result {
                XCTAssertEqual(followRequests.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Approve or deny follower requests

    func test_approve_follow_request() throws {
        try mock(.GET, "https://api.trakt.tv/users/requests/123", result: .success(jsonData(named: "test_approve_follow_request")))

        let expectation = XCTestExpectation(description: "Approve follow request")
        traktManager.approveFollowRequest(requestID: 123) { result in
            if case .success(let followResult) = result {
                XCTAssertEqual(followResult.user.username, "sean")
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_deny_follow_request() throws {
        try mock(.DELETE, "https://api.trakt.tv/users/requests/123", result: .success(.init()))

        let expectation = XCTestExpectation(description: "Deny follow request")
        traktManager.denyFollowRequest(requestID: 123) { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_deny_follow_request_async() async throws {
        try mock(.DELETE, "https://api.trakt.tv/users/requests/123", result: .success(.init()))

        try await traktManager.currentUser().denyFollowRequest(id: 123).perform()
    }

    // MARK: - Saved filters

    func test_get_saved_filters() async throws {
        try mock(.GET, "https://api.trakt.tv/users/saved_filters", result: .success(jsonData(named: "test_get_saved_filters")))

        let filters = try await traktManager.currentUser().savedFilters().perform().object
        XCTAssertEqual(filters.count, 4)

        let firstFilter = try XCTUnwrap(filters.first)
        XCTAssertEqual(firstFilter.id, 101)
    }

    // MARK: - Hidden items

    func test_get_hidden_items() throws {
        try mock(.GET, "https://api.trakt.tv/users/hidden/progress_watched?page=1&limit=10&type=show&extended=min", result: .success(jsonData(named: "test_get_hidden_items")))

        let expectation = XCTestExpectation(description: "HiddenItems")
        traktManager.hiddenItems(section: HiddenItemSection.progressWatched, type: .Show, pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let hiddenShows, _, _) = result {
                XCTAssertEqual(hiddenShows.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Add hidden item

    func test_add_hidden_item() throws {
        try mock(.POST, "https://api.trakt.tv/users/hidden/calendar", result: .success(jsonData(named: "test_add_hidden_item")))

        let expectation = XCTestExpectation(description: "Add hidden item")
        try traktManager.hide(from: HiddenItemSection.calendar) { result in
            if case .success(let result) = result {
                XCTAssertEqual(result.added.movies, 1)
                XCTAssertEqual(result.added.shows, 2)
                XCTAssertEqual(result.added.seasons, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Remove hidden item

    func test_post_remove_hidden_items() throws {
        try mock(.GET, "https://api.trakt.tv/users/hidden/calendar/remove", result: .success(jsonData(named: "test_post_remove_hidden_items")))

        let expectation = XCTestExpectation(description: "Remove hidden items")
        try traktManager.unhide(from: HiddenItemSection.calendar) { result in
            if case .success(let result) = result {
                XCTAssertEqual(result.deleted.movies, 1)
                XCTAssertEqual(result.deleted.shows, 2)
                XCTAssertEqual(result.deleted.seasons, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Likes

    func test_get_comments_likes() throws {
        try mock(.GET, "https://api.trakt.tv/users/likes/comments", result: .success(jsonData(named: "test_get_comments_likes")))

        let expectation = XCTestExpectation(description: "Comments likes")
        traktManager.getLikes(type: .Comments) { result in
            if case .success(let likes) = result {
                XCTAssertEqual(likes.count, 1)
                let like = likes.first!
                XCTAssertEqual(like.type, .comment)
                XCTAssertNotNil(like.comment)
                XCTAssertNil(like.list)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_lists_likes() throws {
        try mock(.GET, "https://api.trakt.tv/users/likes/lists", result: .success(jsonData(named: "test_get_lists_likes")))

        let expectation = XCTestExpectation(description: "Lists likes")
        traktManager.getLikes(type: .Lists) { result in
            if case .success(let likes) = result {
                XCTAssertEqual(likes.count, 1)
                let like = likes.first!
                XCTAssertEqual(like.type, .list)
                XCTAssertNotNil(like.list)
                XCTAssertNil(like.comment)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Profile

    func test_get_min_profile() throws {
        try mock(.GET, "https://api.trakt.tv/users/me?extended=min", result: .success(jsonData(named: "test_get_min_profile")))

        let expectation = XCTestExpectation(description: "User Profile")
        traktManager.getUserProfile { result in
            if case .success(let user) = result {
                XCTAssertEqual(user.username, "sean")
                XCTAssertEqual(user.isPrivate, false)
                XCTAssertEqual(user.isVIP, true)
                XCTAssertEqual(user.isVIPEP, true)
                XCTAssertEqual(user.name, "Sean Rudford")
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_profile() throws {
        try mock(.GET, "https://api.trakt.tv/users/me?extended=full", result: .success(jsonData(named: "test_get_full_profile")))

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
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_VIP_profile() throws {
        try mock(.GET, "https://api.trakt.tv/users/me?extended=full", result: .success(jsonData(named: "test_get_VIP_profile")))

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
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Collection

    func test_get_user_collection() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/collection/shows", result: .success(jsonData(named: "test_get_user_collection")))

        let expectation = XCTestExpectation(description: "Get User Collection")
        traktManager.getUserCollection(type: .shows) { result in
            if case .success(let collection) = result {
                let shows = collection.map { $0.show }
                let seasons = collection.map { $0.seasons }
                XCTAssertEqual(shows.count, 2)
                XCTAssertEqual(seasons.count, 2)
                
                if let metadata = collection.first(where: { $0.show?.ids.trakt == 245 })?.seasons?.first?.episodes.first?.metadata {
                    XCTAssertEqual(metadata.mediaType, .bluray)
                    XCTAssertNil(metadata.resolution)
                    XCTAssertNil(metadata.hdr)
                    XCTAssertEqual(metadata.audio, .dtsHDMA)
                    XCTAssertNil(metadata.audioChannels)
                    XCTAssertFalse(metadata.is3D)
                } else {
                    XCTFail("Failed to parse metadata")
                }
                
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comments

    func test_get_user_comments() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/comments", result: .success(jsonData(named: "test_get_user_comments")))

        let expectation = XCTestExpectation(description: "User Commets")
        traktManager.getUserComments(username: "sean") { result in
            if case .success(let comments) = result {
                XCTAssertEqual(comments.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_custom_lists() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/lists", result: .success(jsonData(named: "test_get_custom_lists")))

        let expectation = XCTestExpectation(description: "User Custom Lists")
        traktManager.getCustomLists(username: "sean") { result in
            if case .success(let customLists) = result {
                XCTAssertEqual(customLists.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_post_custom_list() throws {
        try mock(.POST, "https://api.trakt.tv/users/me/lists", result: .success(jsonData(named: "test_post_custom_list")))
        
        let expectation = XCTestExpectation(description: "User create custom lists")

        let listName = "Star Wars in machete order"
        let listDescription = "Next time you want to introduce someone to Star Wars for the first time, watch the films with them in this order: IV, V, II, III, VI."
        try traktManager.createCustomList(listName: "listName", listDescription: listDescription) { result in
            if case .success(let newList) = result {
                XCTAssertEqual(newList.name, listName)
                XCTAssertEqual(newList.description, listDescription)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - List

    func test_get_custom_list() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/lists/star-wars-in-machete-order", result: .success(jsonData(named: "test_get_custom_list")))

        let expectation = XCTestExpectation(description: "User create custom list")
        traktManager.getCustomList(listID: "star-wars-in-machete-order") { result in
            if case .success(let list) = result {
                XCTAssertEqual(list.name, "Star Wars in machete order")
                XCTAssertNotNil(list.description)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_update_custom_list() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/lists/star-wars-in-machete-order", result: .success(jsonData(named: "test_update_custom_list")))

        let expectation = XCTestExpectation(description: "User update custom list")
        try traktManager.updateCustomList(listID: "star-wars-in-machete-order", listName: "Star Wars in NEW machete order", privacy: "private", displayNumbers: false) { result in
            if case .success(let list) = result {
                XCTAssertEqual(list.name, "Star Wars in NEW machete order")
                XCTAssertEqual(list.privacy, .private)
                XCTAssertEqual(list.displayNumbers, false)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_delete_custom_list() throws {
        try mock(.DELETE, "https://api.trakt.tv/users/me/lists/star-wars-in-machete-order", result: .success(.init()))

        let expectation = XCTestExpectation(description: "User delete custom list")
        traktManager.deleteCustomList(listID: "star-wars-in-machete-order") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - List like

    func test_like_list() throws {
        try mock(.POST, "https://api.trakt.tv/users/sean/lists/star-wars-in-machete-order/like", result: .success(.init()))

        let expectation = XCTestExpectation(description: "Like a list")
        traktManager.likeList(username: "sean", listID: "star-wars-in-machete-order") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_remove_like_from_list() throws {
        try mock(.DELETE, "https://api.trakt.tv/users/sean/lists/star-wars-in-machete-order/like", result: .success(.init()))

        let expectation = XCTestExpectation(description: "Like a list")
        traktManager.removeListLike(username: "sean", listID: "star-wars-in-machete-order") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - List items

    func test_get_items_on_custom_list() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/lists/star-wars-in-machete-order/items?extended=min", result: .success(jsonData(named: "test_get_items_on_custom_list")))

        let expectation = XCTestExpectation(description: "Get custom list items")
        traktManager.getItemsForCustomList(username: "sean", listID: "star-wars-in-machete-order") { result in
            switch result {
            case .success(let listItems):
                XCTAssertEqual(listItems.count, 5)
                expectation.fulfill()
            case .error(let error):
                XCTFail("Failed to get items on custom list: \(String(describing: error))")
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Add list items

    func test_add_item_to_custom_list() throws {
        try mock(.POST, "https://api.trakt.tv/users/sean/lists/star-wars-in-machete-order/items", result: .success(jsonData(named: "test_add_item_to_custom_list")))
        
        let expectation = XCTestExpectation(description: "Add item to custom list")
        try traktManager.addItemToCustomList(username: "sean", listID: "star-wars-in-machete-order", movies: [], shows: [], episodes: []) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response.added.seasons, 1)
                XCTAssertEqual(response.added.people, 1)
                XCTAssertEqual(response.added.movies, 1)
                XCTAssertEqual(response.added.shows, 1)
                XCTAssertEqual(response.added.episodes, 2)

                XCTAssertEqual(response.existing.seasons, 0)
                XCTAssertEqual(response.existing.episodes, 0)
                XCTAssertEqual(response.existing.movies, 0)
                XCTAssertEqual(response.existing.shows, 0)
                XCTAssertEqual(response.existing.episodes, 0)

                XCTAssertEqual(response.notFound.movies.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Remove list items

    func test_remove_item_from_custom_list() throws {
        try mock(.DELETE, "https://api.trakt.tv/users/sean/lists/star-wars-in-machete-order/items/remove", result: .success(jsonData(named: "test_remove_item_from_custom_list")))

        let expectation = XCTestExpectation(description: "Remove item to custom list")
        try traktManager.removeItemFromCustomList(username: "sean", listID: "star-wars-in-machete-order", movies: [], shows: [], episodes: []) { result in
            if case .success(let response) = result {
                XCTAssertEqual(response.deleted.seasons, 1)
                XCTAssertEqual(response.deleted.people, 1)
                XCTAssertEqual(response.deleted.movies, 1)
                XCTAssertEqual(response.deleted.shows, 1)
                XCTAssertEqual(response.deleted.episodes, 2)

                XCTAssertEqual(response.notFound.movies.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - List comments

    func test_get_all_list_comments() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/lists/star-wars-in-machete-order/comments", result: .success(jsonData(named: "test_get_all_list_comments")))

        let expectation = XCTestExpectation(description: "List comments")
        traktManager.getUserAllListComments(username: "sean", listID: "star-wars-in-machete-order") { result in
            if case .success(let comments, _, _) = result {
                XCTAssertEqual(comments.count, 1)
                let firstComment = comments.first
                XCTAssertNotNil(firstComment)
                XCTAssertEqual(firstComment!.review, false)
                XCTAssertNil(firstComment!.userRating)
                XCTAssertEqual(firstComment!.replies, 0)
                XCTAssertEqual(firstComment!.comment, "Can't wait to watch everything on this epic list!")
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Follow

    func test_follow_user() throws {
        try mock(.POST, "https://api.trakt.tv/users/sean/follow", result: .success(jsonData(named: "test_follow_user")))

        let expectation = XCTestExpectation(description: "Follow user")
        traktManager.followUser(username: "sean") { result in
            if case .success(let followResult) = result {
                XCTAssertEqual(followResult.user.username, "sean")
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_unfollow_user() throws {
        try mock(.DELETE, "https://api.trakt.tv/users/sean/follow", result: .success(jsonData(named: "test_follow_user")))

        let expectation = XCTestExpectation(description: "Unfollow user")
        traktManager.unfollowUser(username: "sean") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Followers

    func test_get_followers() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/followers", result: .success(jsonData(named: "test_get_followers")))

        let expectation = XCTestExpectation(description: "Get followers")
        traktManager.getUserFollowers { result in
            if case .success(let followers) = result {
                XCTAssertEqual(followers.count, 2)
                let expectedUserNames = ["sean", "justin"]
                zip(followers, expectedUserNames).forEach {
                    XCTAssertEqual($0.user.username, $1)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Following

    func test_get_following() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/following", result: .success(jsonData(named: "test_get_following")))

        let expectation = XCTestExpectation(description: "Get following")
        traktManager.getUserFollowing { result in
            if case .success(let followers) = result {
                XCTAssertEqual(followers.count, 2)
                let expectedUserNames = ["sean", "justin"]
                zip(followers, expectedUserNames).forEach {
                    XCTAssertEqual($0.user.username, $1)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Friends

    func test_get_friends() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/friends", result: .success(jsonData(named: "test_get_friends")))

        let expectation = XCTestExpectation(description: "Get friends")
        traktManager.getUserFriends { result in
            if case .success(let followers) = result {
                XCTAssertEqual(followers.count, 2)
                let expectedUserNames = ["sean", "justin"]
                zip(followers, expectedUserNames).forEach {
                    XCTAssertEqual($0.user.username, $1)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - History

    func test_get_user_watched_history() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/history?extended=min", result: .success(jsonData(named: "test_get_user_watched_history")))

        let expectation = XCTestExpectation(description: "Get user watched history")
        traktManager.getUserWatchedHistory(username: "sean") { result in
            if case .success(let history, _, _) = result {
                XCTAssertEqual(history.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Ratings

    func test_get_user_ratings() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/ratings", result: .success(jsonData(named: "test_get_user_ratings")))

        let expectation = XCTestExpectation(description: "Get user ratings")
        traktManager.getUserRatings(username: "sean") { result in
            if case .success(let ratings) = result {
                XCTAssertEqual(ratings.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watchlist

    func test_get_user_watchlist() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/watchlist/movies?extended=min", result: .success(jsonData(named: "test_get_user_watchlist")))

        let expectation = XCTestExpectation(description: "Get user watchlist")
        traktManager.getUserWatchlist(username: "sean", type: .Movies, extended: [.Min]) { result in
            switch result {
            case .success(let watchlist):
                XCTAssertEqual(watchlist.count, 5)
                expectation.fulfill()
            case .error(let error):
                XCTFail("Failed to get user watchlist: \(String(describing: error))")
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watching

    func test_get_user_watching() throws {
        try mock(.GET, "https://api.trakt.tv/users/sean/watching", result: .success(jsonData(named: "test_get_user_watching")))

        let expectation = XCTestExpectation(description: "Get watching")
        traktManager.getUserWatching(username: "sean") { result in
            defer { expectation.fulfill() }
            switch result {
            case .success(let response):
                XCTAssertTrue(response.isWatching)
                switch response {
                case .watching(let item):
                    XCTAssertEqual(item.action, "scrobble")
                    XCTAssertEqual(item.mediaType, .episode)
                    switch item.mediaItem {
                    case let .episode(episode, show):
                        XCTAssertEqual(episode.number, 2)
                        XCTAssertEqual(show.title, "Breaking Bad")
                    case .movie:
                        XCTFail("Media item should be episode")
                    }
                case .notWatchingAnything:
                    XCTFail("User should be watching an episode")
                }
            case .error:
                XCTFail("Mocked request should not fail")
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watched movies / shows

    func test_get_user_watched_movies() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/watched/movies?extended=min", result: .success(jsonData(named: "test_get_user_watched_movies")))

        let expectation = XCTestExpectation(description: "User Watched movies")
        traktManager.getUserWatched(type: .movies) { result in
            if case .success(let watched) = result {
                XCTAssertEqual(watched.count, 2)
                let expectedMovieTitles = ["Batman Begins", "The Dark Knight"]
                zip(watched, expectedMovieTitles).forEach { watchedMovie, movieTitle in
                    XCTAssertEqual(watchedMovie.movie?.title, movieTitle)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_user_watched_shows() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/watched/shows?extended=min", result: .success(jsonData(named: "test_get_user_watched_shows")))

        let expectation = XCTestExpectation(description: "User Watched shows")
        traktManager.getUserWatched(type: .shows) { result in
            if case .success(let watched) = result {
                XCTAssertEqual(watched.count, 2)
                let expectedShowTitles = ["Breaking Bad", "Parks and Recreation"]
                zip(watched, expectedShowTitles).forEach { watchedShow, showTitle in
                    XCTAssertEqual(watchedShow.show?.title, showTitle)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_user_watched_shows_no_seasons() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/watched/shows?extended=noseasons", result: .success(jsonData(named: "test_get_user_watched_shows_no_seasons")))

        let expectation = XCTestExpectation(description: "User Watched shows without seasons")
        traktManager.getUserWatched(type: .shows, extended: [.noSeasons]) { result in
            if case .success(let watched) = result {
                XCTAssertEqual(watched.count, 2)
                let expectedShowTitles = ["Breaking Bad", "Parks and Recreation"]
                zip(watched, expectedShowTitles).forEach { watchedShow, showTitle in
                    XCTAssertEqual(watchedShow.show?.title, showTitle)
                    XCTAssertNil(watchedShow.seasons)
                }
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Stats

    func test_get_user_stats() throws {
        try mock(.GET, "https://api.trakt.tv/users/me/stats", result: .success(jsonData(named: "test_get_user_stats")))

        let expectation = XCTestExpectation(description: "User Stats")
        traktManager.getUserStats { result in
            if case .success(let stats) = result {
                XCTAssertEqual(stats.movies.plays, 155)
                XCTAssertEqual(stats.movies.watched, 114)
                XCTAssertEqual(stats.movies.minutes, 15650)
                XCTAssertEqual(stats.movies.collected, 933)
                XCTAssertEqual(stats.movies.ratings, 256)
                XCTAssertEqual(stats.movies.comments, 28)

                XCTAssertEqual(stats.shows.watched, 16)
                XCTAssertEqual(stats.shows.collected, 7)
                XCTAssertEqual(stats.shows.ratings, 63)
                XCTAssertEqual(stats.shows.comments, 20)

                XCTAssertEqual(stats.seasons.ratings, 6)
                XCTAssertEqual(stats.seasons.comments, 1)

                XCTAssertEqual(stats.episodes.plays, 552)
                XCTAssertEqual(stats.episodes.watched, 534)
                XCTAssertEqual(stats.episodes.minutes, 17330)
                XCTAssertEqual(stats.episodes.collected, 117)
                XCTAssertEqual(stats.episodes.ratings, 64)
                XCTAssertEqual(stats.episodes.comments, 14)

                XCTAssertEqual(stats.network.friends, 1)
                XCTAssertEqual(stats.network.followers, 4)
                XCTAssertEqual(stats.network.following, 11)

                XCTAssertEqual(stats.ratings.total, 389)
                XCTAssertEqual(stats.ratings.distribution.one, 18)
                XCTAssertEqual(stats.ratings.distribution.two, 1)
                XCTAssertEqual(stats.ratings.distribution.three, 4)
                XCTAssertEqual(stats.ratings.distribution.four, 1)
                XCTAssertEqual(stats.ratings.distribution.five, 10)
                XCTAssertEqual(stats.ratings.distribution.six, 9)
                XCTAssertEqual(stats.ratings.distribution.seven, 37)
                XCTAssertEqual(stats.ratings.distribution.eight, 37)
                XCTAssertEqual(stats.ratings.distribution.nine, 57)
                XCTAssertEqual(stats.ratings.distribution.ten, 215)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
