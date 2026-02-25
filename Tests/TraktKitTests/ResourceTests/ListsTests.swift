//
//  ListsTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/19/26.
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct ListsTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        // MARK: - Trending

        @Test func getTrendingLists() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/lists/trending?page=1&limit=10",
                result: .success(jsonData(named: "test_get_trending_lists")),
                headers: [.page(1), .pageCount(5)]
            )

            let result = try await traktManager.lists
                .trending()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.currentPage == 1)
            #expect(result.pageCount == 5)
            #expect(result.object.count == 2)
            let first = try #require(result.object.first)
            #expect(first.list.name == "Incredible Thoughts")
            #expect(first.list.ids.slug == "incredible-thoughts")
            #expect(first.likeCount == 2)
            #expect(first.commentCount == 1)
        }

        // MARK: - Popular

        @Test func getPopularLists() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/lists/popular?page=1&limit=10",
                result: .success(jsonData(named: "test_get_popular_lists")),
                headers: [.page(1), .pageCount(3)]
            )

            let result = try await traktManager.lists
                .popular()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.currentPage == 1)
            #expect(result.pageCount == 3)
            #expect(result.object.count == 2)
            let first = try #require(result.object.first)
            #expect(first.list.name == "Top 100 Movies")
            #expect(first.list.ids.slug == "top-100-movies")
            #expect(first.likeCount == 120)
        }

        // MARK: - Summary

        @Test func getListSummary() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/lists/star-wars-in-machete-order",
                result: .success(jsonData(named: "test_get_list_summary"))
            )

            let list = try await traktManager.list(id: "star-wars-in-machete-order")
                .summary()
                .perform()

            #expect(list.name == "Star Wars in Machete Order")
            #expect(list.ids.slug == "star-wars-in-machete-order")
            #expect(list.ids.trakt == 1337)
            #expect(list.itemCount == 4)
            #expect(list.privacy == .public)
        }

        // MARK: - Items

        @Test func getListItems() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/lists/star-wars-in-machete-order/items?page=1&limit=10",
                result: .success(jsonData(named: "test_get_list_items")),
                headers: [.page(1), .pageCount(1)]
            )

            let result = try await traktManager.list(id: "star-wars-in-machete-order")
                .items()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 3)
            let first = try #require(result.object.first)
            #expect(first.rank == 1)
            #expect(first.type == "movie")
            #expect(first.notes == "The one that started it all.")
            #expect(first.movie?.title == "Star Wars: Episode IV - A New Hope")
        }

        @Test func getListItemsFilteredByType() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/lists/star-wars-in-machete-order/items/movie",
                result: .success(jsonData(named: "test_get_list_items"))
            )

            let result = try await traktManager.list(id: "star-wars-in-machete-order")
                .items(type: .movies)
                .perform()

            #expect(result.object.count == 3)
            #expect(result.object.allSatisfy { $0.type == "movie" })
        }

        // MARK: - Comments

        @Test func getListComments() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/lists/star-wars-in-machete-order/comments?page=1&limit=10",
                result: .success(jsonData(named: "test_get_list_comments")),
                headers: [.page(1), .pageCount(1)]
            )

            let result = try await traktManager.list(id: "star-wars-in-machete-order")
                .comments()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 2)
            let first = try #require(result.object.first)
            #expect(first.id == 190)
            #expect(first.spoiler == false)
            #expect(first.user.username == "sean")
        }

        // MARK: - Likes

        @Test func getListLikes() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/lists/star-wars-in-machete-order/likes?page=1&limit=10",
                result: .success(jsonData(named: "test_get_list_likes")),
                headers: [.page(1), .pageCount(1)]
            )

            let result = try await traktManager.list(id: "star-wars-in-machete-order")
                .likes()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 2)
            let first = try #require(result.object.first)
            #expect(first.type == .list)
            #expect(first.list?.ids.slug == "star-wars-in-machete-order")
        }

        // MARK: - Like / Unlike

        @Test func likeList() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/lists/star-wars-in-machete-order/like", result: .success(.init()))

            try await traktManager.list(id: "star-wars-in-machete-order")
                .like()
                .perform()
        }

        @Test func removeLikeFromList() async throws {
            try await suite.mock(.DELETE, "https://api.trakt.tv/lists/star-wars-in-machete-order/like", result: .success(.init()))

            try await traktManager.list(id: "star-wars-in-machete-order")
                .removeLike()
                .perform()
        }
    }
}
