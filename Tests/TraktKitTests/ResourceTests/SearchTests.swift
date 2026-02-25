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

            #expect(searchResults.count == 5)
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
