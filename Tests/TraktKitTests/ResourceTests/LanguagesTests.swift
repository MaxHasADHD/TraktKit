//
//  LanguagesTests.swift
//  TraktKit
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct LanguagesTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        @Test func getLanguagesForMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/languages/movies", result: .success(jsonData(named: "test_get_languages")))

            let languages = try await traktManager.languages
                .list(type: .Movies)
                .perform()

            #expect(languages.count == 3)
            let first = try #require(languages.first)
            #expect(first.name == "English")
            #expect(first.code == "en")
        }

        @Test func getLanguagesForShows() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/languages/shows", result: .success(jsonData(named: "test_get_languages")))

            let languages = try await traktManager.languages
                .list(type: .Shows)
                .perform()

            #expect(languages.count == 3)
            let first = try #require(languages.first)
            #expect(first.name == "English")
            #expect(first.code == "en")
        }
    }
}
