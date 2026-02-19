//
//  CountriesTests+Async.swift
//  TraktKit
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct CountriesTestSuite {

        @Test func getCountriesForMovies() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/countries/movies", result: .success(jsonData(named: "test_get_countries")))

            let countries = try await traktManager.countries
                .list(type: .Movies)
                .perform()

            #expect(countries.count == 3)
            let first = try #require(countries.first)
            #expect(first.name == "Australia")
            #expect(first.code == "au")
        }

        @Test func getCountriesForShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/countries/shows", result: .success(jsonData(named: "test_get_countries")))

            let countries = try await traktManager.countries
                .list(type: .Shows)
                .perform()

            #expect(countries.count == 3)
            let first = try #require(countries.first)
            #expect(first.name == "Australia")
            #expect(first.code == "au")
        }
    }
}
