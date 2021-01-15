//
//  CommentTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class CommentTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    // MARK: - Comments

    func test_post_a_comment() {
        session.nextData = jsonData(named: "test_post_a_comment")
        session.nextStatusCode = StatusCodes.SuccessNewResourceCreated

        let expectation = XCTestExpectation(description: "Post a comment")
        try! traktManager.postComment(movie: SyncId(trakt: 12345), comment: "Oh, I wasn't really listening.", isSpoiler: false) { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comment

    func test_get_a_comment() {
        session.nextData = jsonData(named: "test_get_a_comment")

        let expectation = XCTestExpectation(description: "Get a comment")
        traktManager.getComment(commentID: "417") { result in
            if case .success(let comment) = result {
                XCTAssertEqual(comment.likes, 0)
                XCTAssertEqual(comment.userRating, 8)
                XCTAssertEqual(comment.spoiler, false)
                XCTAssertEqual(comment.review, false)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_update_a_comment() {
        session.nextData = jsonData(named: "test_update_a_comment")

        let newComment = "Agreed, this show is awesome. AMC in general has awesome shows and I can't wait to see what they come up with next."

        let expectation = XCTestExpectation(description: "Update a comment")
        try! traktManager.updateComment(commentID: "417", newComment: newComment) { result in
            if case .success(let comment) = result {
                XCTAssertEqual(comment.comment, newComment)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_delete_a_comment() {
        session.nextStatusCode = StatusCodes.SuccessNoContentToReturn

        let expectation = XCTestExpectation(description: "Delete a comment")
        traktManager.deleteComment(commentID: "417") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Replies

    func test_get_replies_for_comment() {
        session.nextData = jsonData(named: "test_get_replies_for_comment")

        let expectation = XCTestExpectation(description: "Get replies for comment")
        traktManager.getReplies(commentID: "417") { result in
            if case .success(let replies) = result {
                XCTAssertEqual(replies.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417/replies")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_post_reply_for_comment() {
        session.nextData = jsonData(named: "test_post_reply_for_comment")

        let reply = "Couldn't agree more with your review!"

        let expectation = XCTestExpectation(description: "Get replies for comment")
        try! traktManager.postReply(commentID: "417", comment: reply) { result in
            if case .success(let postedReply) = result {
                XCTAssertEqual(postedReply.comment, reply)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417/replies")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Item

    func test_get_attached_media_item() {
        session.nextData = jsonData(named: "test_get_attached_media_item")

        let expectation = XCTestExpectation(description: "Get attached media item")
        traktManager.getAttachedMediaItem(commentID: "417") { result in
            if case .success(let mediaItem) = result {
                XCTAssertNotNil(mediaItem.show)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417/item")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Likes

    func test_users_who_liked_comment() {
        session.nextData = jsonData(named: "test_users_who_liked_comment")

        let expectation = XCTestExpectation(description: "Get users who liked comment")
        traktManager.getUsersWhoLikedComment(commentID: "417") { result in
            if case .success(let users) = result {
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417/likes")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Like

    func test_like_a_comment() {
        session.nextStatusCode = StatusCodes.SuccessNoContentToReturn

        let expectation = XCTestExpectation(description: "Like  a comment")
        traktManager.likeComment(commentID: "417") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417/like")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_remove_like() {
        session.nextStatusCode = StatusCodes.SuccessNoContentToReturn

        let expectation = XCTestExpectation(description: "Like  a comment")
        traktManager.removeLikeOnComment(commentID: "417") { result in
            if case .success = result {
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/417/like")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Trending

    func test_get_trending_comments() {
        session.nextData = jsonData(named: "test_get_trending_comments")

        let expectation = XCTestExpectation(description: "Get trending comments")
        traktManager.getTrendingComments(commentType: .all, mediaType: .All, includeReplies: true) { result in
            if case .success(let trendingComments) = result {
                XCTAssertEqual(trendingComments.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/trending/all/all?include_replies=true")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Recent

    func test_get_recently_created_comments() {
        session.nextData = jsonData(named: "test_get_recently_created_comments")

        let expectation = XCTestExpectation(description: "Get recently created comments")
        traktManager.getRecentComments(commentType: .all, mediaType: .All, includeReplies: true) { result in
            if case .success(let recentComments) = result {
                XCTAssertEqual(recentComments.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/recent/all/all?include_replies=true")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Updates

    func test_get_recently_updated_comments() {
        session.nextData = jsonData(named: "test_get_recently_updated_comments")

        let expectation = XCTestExpectation(description: "Get recently updated comments")
        traktManager.getRecentlyUpdatedComments(commentType: .all, mediaType: .All, includeReplies: true) { result in
            if case .success(let recentComments) = result {
                XCTAssertEqual(recentComments.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/comments/updates/all/all?include_replies=true")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
