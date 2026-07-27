//
//  SearchTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/29/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Search Tests")
    struct SearchTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }


        // MARK: - Text query

        @Test func searchQuery() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/search/movie,show,episode,person,list?query=tron&extended=min", result: .success(jsonData(named: "test_search_query")))

            let searchResults = try await traktManager.search()
                .search("tron", types: [.movie, .show, .episode, .person, .list])
                .extend(.Min)
                .perform()
                .object

            #expect(searchResults.count == 5)
        }

        @Test func exactSearchQuery() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/search/show/exact?query=mom&extended=full,images&page=1&limit=25",
                result: .success(jsonData(named: "test_search_shows_paged")),
                headers: [.contentType, .apiVersion, .apiKey(""), .page(1), .pageCount(3)]
            )

            let result = try await traktManager.search()
                .exactSearch("mom", types: [.show])
                .extend(.Full, .images)
                .page(1)
                .limit(25)
                .perform()

            #expect(result.object.count == 3)
            #expect(result.currentPage == 1)
            #expect(result.pageCount == 3)
            #expect(result.object.allSatisfy { $0.type == "show" })
        }

        /// Both real-world list shapes decode: a personal list carries its owner (with a slug),
        /// and a Trakt *official* list carries the placeholder owner whose `ids.slug` is null —
        /// which must not fail the page (it did, before `User.IDs.slug` became optional).
        @Test func searchListsIncludesOwnersAndToleratesOfficialLists() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/search/list?query=marvel", result: .success(jsonData(named: "test_search_lists")))

            let searchResults = try await traktManager.search()
                .search("marvel", types: [.list])
                .perform()
                .object

            #expect(searchResults.count == 2)

            let personal = try #require(searchResults[0].list)
            #expect(personal.name == "MARVEL Cinematic Universe")
            #expect(personal.user?.ids.slug == "donxy")

            let official = try #require(searchResults[1].list)
            #expect(official.name == "Marvel Animated Features")
            #expect(official.user != nil)
            #expect(official.user?.ids.slug == nil)
        }

        // MARK: - ID Lookup

        @Test func idLookup() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/search/imdb/tt0848228?type=movie&extended=min", result: .success(jsonData(named: "test_id_lookup")))

            let lookupResults = try await traktManager.search()
                .lookup(.IMDB(id: "tt0848228"))
                .extend(.Min)
                .type(.movie)
                .perform()

            #expect(lookupResults.count == 1)
        }
    }
}
