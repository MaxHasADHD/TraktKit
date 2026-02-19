//
//  CalendarTests+Async.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/19/26.
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct CalendarTestSuite {

        /// A fixed test date of 2014-09-01 in UTC.
        private static var testDate: Date {
            var components = DateComponents()
            components.timeZone = TimeZone(identifier: "UTC")
            components.year = 2014
            components.month = 9
            components.day = 1
            return Calendar(identifier: .gregorian).date(from: components)!
        }

        // MARK: - My Calendar

        @Test func getMyShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/my/shows/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_shows")))

            let shows = try await traktManager.myCalendar
                .shows(startDate: Self.testDate, days: 7)
                .perform()

            #expect(shows.count == 2)
            let first = try #require(shows.first)
            #expect(first.show.title == "Breaking Bad")
            #expect(first.episode.season == 5)
            #expect(first.episode.number == 1)
        }

        @Test func getMyNewShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/my/shows/new/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_new_shows")))

            let shows = try await traktManager.myCalendar
                .newShows(startDate: Self.testDate, days: 7)
                .perform()

            #expect(shows.count == 1)
            let first = try #require(shows.first)
            #expect(first.episode.season == 1)
            #expect(first.episode.number == 1)
        }

        @Test func getMySeasonPremieres() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/my/shows/premieres/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_season_premieres")))

            let shows = try await traktManager.myCalendar
                .seasonPremieres(startDate: Self.testDate, days: 7)
                .perform()

            #expect(shows.count == 2)
            #expect(shows.allSatisfy { $0.episode.number == 1 })
        }

        @Test func getMyMovies() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/my/movies/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_movies")))

            let movies = try await traktManager.myCalendar
                .movies(startDate: Self.testDate, days: 7)
                .perform()

            #expect(movies.count == 2)
            let first = try #require(movies.first)
            #expect(first.movie.title == "The Maze Runner")
            #expect(first.movie.year == 2014)
        }

        @Test func getMyDVD() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/my/dvd/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_dvd")))

            let movies = try await traktManager.myCalendar
                .dvd(startDate: Self.testDate, days: 7)
                .perform()

            #expect(movies.count == 2)
            let first = try #require(movies.first)
            #expect(first.movie.title == "The Dark Knight")
        }

        // MARK: - All Calendar

        @Test func getAllShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/all/shows/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_shows")))

            let shows = try await traktManager.allCalendar
                .shows(startDate: Self.testDate, days: 7)
                .perform()

            #expect(shows.count == 2)
            let first = try #require(shows.first)
            #expect(first.show.title == "Breaking Bad")
        }

        @Test func getAllNewShows() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/all/shows/new/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_new_shows")))

            let shows = try await traktManager.allCalendar
                .newShows(startDate: Self.testDate, days: 7)
                .perform()

            #expect(shows.count == 1)
            let first = try #require(shows.first)
            #expect(first.show.title == "Utopia")
        }

        @Test func getAllSeasonPremieres() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/all/shows/premieres/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_season_premieres")))

            let shows = try await traktManager.allCalendar
                .seasonPremieres(startDate: Self.testDate, days: 7)
                .perform()

            #expect(shows.count == 2)
            #expect(shows.allSatisfy { $0.episode.number == 1 })
        }

        @Test func getAllMovies() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/all/movies/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_movies")))

            let movies = try await traktManager.allCalendar
                .movies(startDate: Self.testDate, days: 7)
                .perform()

            #expect(movies.count == 2)
            let first = try #require(movies.first)
            #expect(first.movie.title == "The Maze Runner")
        }

        @Test func getAllDVD() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/calendars/all/dvd/2014-09-01/7", result: .success(jsonData(named: "test_get_calendar_dvd")))

            let movies = try await traktManager.allCalendar
                .dvd(startDate: Self.testDate, days: 7)
                .perform()

            #expect(movies.count == 2)
            let first = try #require(movies.first)
            #expect(first.movie.title == "The Dark Knight")
        }
    }
}
