//
//  GenresTests+Async.swift
//  TraktKit
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct GenresTestSuite {

        @Test func getGenresForMovies() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/genres/movies", result: .success(jsonData(named: "test_get_genres")))

            let genres = try await traktManager.genres
                .list(type: .Movies)
                .perform()

            #expect(genres.count == 3)
            let first = try #require(genres.first)
            #expect(first.name == "Action")
            #expect(first.slug == "action")
        }

        @Test func getGenresForShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/genres/shows", result: .success(jsonData(named: "test_get_genres")))

            let genres = try await traktManager.genres
                .list(type: .Shows)
                .perform()

            #expect(genres.count == 3)
            let first = try #require(genres.first)
            #expect(first.name == "Action")
            #expect(first.slug == "action")
        }
    }
}
