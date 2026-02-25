//
//  PeopleTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/18/26.
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct PeopleTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        // MARK: - Updates

        @Test func getRecentlyUpdatedPeople() async throws {
            let startDate = try Date.dateFromString("2022-11-03")
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/people/updates/2022-11-03T00:00:00?page=1&limit=10",
                result: .success(jsonData(named: "test_get_recently_updated_people")),
                headers: [.page(1), .pageCount(5)]
            )

            let result = try await traktManager.people
                .recentlyUpdated(since: startDate)
                .page(1)
                .limit(10)
                .perform()

            #expect(result.currentPage == 1)
            #expect(result.pageCount == 5)
            #expect(result.object.count == 2)
            let first = try #require(result.object.first)
            #expect(first.person.name == "Charlie Cox")
            #expect(first.person.ids.slug == "charlie-cox")
        }

        @Test func getRecentlyUpdatedPeopleIds() async throws {
            let startDate = try Date.dateFromString("2022-11-03")
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/people/updates/id/2022-11-03T00:00:00?page=1&limit=10",
                result: .success(jsonData(named: "test_get_recently_updated_people_ids")),
                headers: [.page(1), .pageCount(3)]
            )

            let result = try await traktManager.people
                .recentlyUpdatedIds(since: startDate)
                .page(1)
                .limit(10)
                .perform()

            #expect(result.currentPage == 1)
            #expect(result.pageCount == 3)
            #expect(result.object.count == 4)
            #expect(result.object.first == 1)
            #expect(result.object.last == 50)
        }

        // MARK: - Summary

        @Test func getPersonMin() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/people/bryan-cranston?extended=min", result: .success(jsonData(named: "Person_Min")))

            let person = try await traktManager.person(id: "bryan-cranston")
                .details()
                .extend(.Min)
                .perform()

            #expect(person.name == "Bryan Cranston")
        }

        @Test func getPersonFull() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/people/bryan-cranston?extended=full", result: .success(jsonData(named: "Person_Full")))

            let person = try await traktManager.person(id: "bryan-cranston")
                .details()
                .extend(.Full)
                .perform()

            #expect(person.name == "Bryan Cranston")
        }

        // MARK: - Movies

        @Test func getMovieCredits() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/people/bryan-cranston/movies?extended=min",
                result: .success(jsonData(named: "test_get_movie_credits"))
            )

            let credits = try await traktManager.person(id: "bryan-cranston")
                .movieCredits()
                .extend(.Min)
                .perform()

            #expect(credits.writers?.count == 2)
            #expect(credits.directors?.count == 1)
            #expect(credits.cast?.count == 69)
        }

        // MARK: - Shows

        @Test func getShowCredits() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/people/bryan-cranston/shows?extended=min",
                result: .success(jsonData(named: "test_get_show_credits"))
            )

            let credits = try await traktManager.person(id: "bryan-cranston")
                .showCredits()
                .extend(.Min)
                .perform()

            #expect(credits.producers?.count == 4)
            #expect(credits.cast?.count == 54)
        }

        // MARK: - Lists

        @Test func getListsContainingPerson() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/people/bryan-cranston/lists", result: .success(jsonData(named: "test_get_lists_containing_this_person")))

            let lists = try await traktManager.person(id: "bryan-cranston")
                .containingLists()
                .perform()
                .object

            #expect(lists.count == 1)
        }

        // MARK: - Refresh

        @Test func refreshPersonMetadata() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/people/bryan-cranston/refresh", result: .success(.init()), replace: true)

            // A successful refresh returns 201 with no body — just confirm it doesn't throw.
            try await traktManager.person(id: "bryan-cranston")
                .refresh()
                .perform()
        }

        @Test func refreshPersonMetadataAlreadyQueued() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/people/bryan-cranston/refresh", result: .success(.init()), httpCode: 409, replace: true)

            // A 409 means the person is already queued — the manager should surface this as an error.
            await #expect(throws: (any Error).self) {
                try await traktManager.person(id: "bryan-cranston")
                    .refresh()
                    .perform()
            }
        }
    }
}
