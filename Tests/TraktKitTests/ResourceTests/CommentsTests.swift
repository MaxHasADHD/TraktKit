//
//  CommentsTests.swift
//  TraktKit
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct CommentsTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        // MARK: - Post

        @Test func postComment() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/comments", result: .success(jsonData(named: "test_post_a_comment")))

            let body = TraktCommentPostBody(
                movie: SyncId(trakt: 12345),
                comment: "Oh, I wasn't really listening.",
                spoiler: false
            )
            let comment = try await traktManager.comments
                .post(body)
                .perform()

            #expect(comment.id == 190)
            #expect(comment.comment == "Oh, I wasn't really listening.")
            #expect(comment.spoiler == false)
            #expect(comment.user.username == "sean")
        }

        // MARK: - Trending

        @Test func getTrendingComments() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/comments/trending/all/movies?include_replies=false&page=1&limit=5",
                result: .success(jsonData(named: "test_get_trending_comments")),
                headers: [.page(1), .pageCount(2)]
            )

            let result = try await traktManager.comments
                .trending(commentType: .all, type: .Movies)
                .page(1)
                .limit(5)
                .perform()

            #expect(result.currentPage == 1)
            #expect(result.pageCount == 2)
            #expect(result.object.count == 5)
            let first = try #require(result.object.first)
            #expect(first.type == "movie")
            #expect(first.movie?.title == "Batman Begins")
        }

        // MARK: - Recent

        @Test func getRecentComments() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/comments/recent/all/movies?include_replies=false&page=1&limit=5",
                result: .success(jsonData(named: "test_get_recently_created_comments")),
                headers: [.page(1), .pageCount(1)]
            )

            let result = try await traktManager.comments
                .recent(commentType: .all, type: .Movies)
                .page(1)
                .limit(5)
                .perform()

            #expect(result.object.count == 5)
            let first = try #require(result.object.first)
            #expect(first.comment.id == 267)
        }

        // MARK: - Updates

        @Test func getUpdatedComments() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/comments/updates/all/movies?include_replies=false&page=1&limit=5",
                result: .success(jsonData(named: "test_get_recently_updated_comments")),
                headers: [.page(1), .pageCount(1)]
            )

            let result = try await traktManager.comments
                .updates(commentType: .all, type: .Movies)
                .page(1)
                .limit(5)
                .perform()

            #expect(result.object.count == 5)
            let first = try #require(result.object.first)
            #expect(first.comment.id == 267)
        }

        // MARK: - Get

        @Test func getComment() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/comments/1", result: .success(jsonData(named: "test_get_a_comment")))

            let comment = try await traktManager.comment(id: 1)
                .get()
                .perform()

            #expect(comment.id == 1)
            #expect(comment.comment == "Agreed, this show is awesome. AMC in general has awesome shows.")
            #expect(comment.spoiler == false)
        }

        // MARK: - Update

        @Test func updateComment() async throws {
            try await suite.mock(.PUT, "https://api.trakt.tv/comments/190", result: .success(jsonData(named: "test_update_a_comment")))

            let body = TraktCommentPostBody(comment: "Oh, I wasn't really listening.", spoiler: false)
            let comment = try await traktManager.comment(id: 190)
                .update(body)
                .perform()

            #expect(comment.id == 1)
        }

        // MARK: - Delete

        @Test func deleteComment() async throws {
            try await suite.mock(.DELETE, "https://api.trakt.tv/comments/190", result: .success(.init()))

            try await traktManager.comment(id: 190)
                .delete()
                .perform()
        }

        // MARK: - Replies

        @Test func getReplies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/comments/417/replies", result: .success(jsonData(named: "test_get_replies_for_comment")), headers: [.page(1), .pageCount(1)], replace: true)

            let replies = try await traktManager.comment(id: 417)
                .replies()
                .perform()
                .object

            #expect(replies.count == 1)
            let first = try #require(replies.first)
            #expect(first.comment == "Season 2 has really picked up the action!")
        }

        @Test func postReply() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/comments/417/replies", result: .success(jsonData(named: "test_post_reply_for_comment")), replace: true)

            let body = TraktCommentPostBody(comment: "Couldn't agree more with your review!")
            let reply = try await traktManager.comment(id: 417)
                .postReply(body)
                .perform()

            #expect(reply.id == 2)
        }

        // MARK: - Item

        @Test func getAttachedItem() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/comments/417/item", result: .success(jsonData(named: "test_get_attached_media_item")))

            let item = try await traktManager.comment(id: 417)
                .item()
                .perform()

            #expect(item.type == "show")
            let show = try #require(item.show)
            #expect(show.title == "Game of Thrones")
        }

        // MARK: - Likes

        @Test func getLikes() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/comments/190/likes", result: .success(jsonData(named: "test_users_who_liked_comment")), headers: [.page(1), .pageCount(1)])

            let likedUsers = try await traktManager.comment(id: 190)
                .likes()
                .perform()
                .object

            #expect(likedUsers.count == 2)
            let first = try #require(likedUsers.first)
            #expect(first.user.username == "sean")
        }

        // MARK: - Like / Remove Like

        @Test func likeComment() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/comments/190/like", result: .success(.init()))

            try await traktManager.comment(id: 190)
                .like()
                .perform()
        }

        @Test func removeLikeOnComment() async throws {
            try await suite.mock(.DELETE, "https://api.trakt.tv/comments/190/like", result: .success(.init()))

            try await traktManager.comment(id: 190)
                .removeLike()
                .perform()
        }
    }
}
