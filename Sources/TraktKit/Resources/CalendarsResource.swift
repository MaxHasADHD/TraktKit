//
//  CalendarResource.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/19/26.
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /// Endpoints for the user's personal calendar. All endpoints require OAuth.
    public struct MyCalendarResource {
        private let traktManager: TraktManager
        private let basePath = "calendars/my"

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Shows

        /**
         Returns all shows airing during the time period specified.

         **Endpoint:** `GET /calendars/my/shows/{start_date}/{days}`

         🔒 OAuth Required • ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func shows(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarShow]> {
            Route(
                paths: [basePath, "shows", startDate?.calendarDateString(), days],
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Returns all new show premieres (season 1, episode 1) airing during the time period specified.

         **Endpoint:** `GET /calendars/my/shows/new/{start_date}/{days}`

         🔒 OAuth Required • ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func newShows(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarShow]> {
            Route(
                paths: [basePath, "shows", "new", startDate?.calendarDateString(), days],
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Returns all show premieres (any season, episode 1) airing during the time period specified.

         **Endpoint:** `GET /calendars/my/shows/premieres/{start_date}/{days}`

         🔒 OAuth Required • ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func seasonPremieres(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarShow]> {
            Route(
                paths: [basePath, "shows", "premieres", startDate?.calendarDateString(), days],
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Returns all movies with a release date during the time period specified.

         **Endpoint:** `GET /calendars/my/movies/{start_date}/{days}`

         🔒 OAuth Required • ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func movies(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarMovie]> {
            Route(
                paths: [basePath, "movies", startDate?.calendarDateString(), days],
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Returns all movies with a DVD release date during the time period specified.

         **Endpoint:** `GET /calendars/my/dvd/{start_date}/{days}`

         🔒 OAuth Required • ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func dvd(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarMovie]> {
            Route(
                paths: [basePath, "dvd", startDate?.calendarDateString(), days],
                method: .GET,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }
    }

    /// Endpoints for the global/all calendar. No authentication required.
    public struct AllCalendarResource {
        private let traktManager: TraktManager
        private let basePath = "calendars/all"

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Shows

        /**
         Returns all shows airing during the time period specified.

         **Endpoint:** `GET /calendars/all/shows/{start_date}/{days}`

         ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func shows(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarShow]> {
            Route(
                paths: [basePath, "shows", startDate?.calendarDateString(), days],
                method: .GET,
                traktManager: traktManager
            )
        }

        /**
         Returns all new show premieres (season 1, episode 1) airing during the time period specified.

         **Endpoint:** `GET /calendars/all/shows/new/{start_date}/{days}`

         ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func newShows(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarShow]> {
            Route(
                paths: [basePath, "shows", "new", startDate?.calendarDateString(), days],
                method: .GET,
                traktManager: traktManager
            )
        }

        /**
         Returns all show premieres (any season, episode 1) airing during the time period specified.

         **Endpoint:** `GET /calendars/all/shows/premieres/{start_date}/{days}`

         ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func seasonPremieres(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarShow]> {
            Route(
                paths: [basePath, "shows", "premieres", startDate?.calendarDateString(), days],
                method: .GET,
                traktManager: traktManager
            )
        }

        /**
         Returns all movies with a release date during the time period specified.

         **Endpoint:** `GET /calendars/all/movies/{start_date}/{days}`

         ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func movies(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarMovie]> {
            Route(
                paths: [basePath, "movies", startDate?.calendarDateString(), days],
                method: .GET,
                traktManager: traktManager
            )
        }

        /**
         Returns all movies with a DVD release date during the time period specified.

         **Endpoint:** `GET /calendars/all/dvd/{start_date}/{days}`

         ✨ Extended Info • 🎚 Filters

         - parameter startDate: Start the calendar on this date. Defaults to today.
         - parameter days: Number of days to display. Defaults to `7`.
         */
        public func dvd(startDate: Date? = nil, days: Int? = nil) -> Route<[CalendarMovie]> {
            Route(
                paths: [basePath, "dvd", startDate?.calendarDateString(), days],
                method: .GET,
                traktManager: traktManager
            )
        }
    }
}

// MARK: - Date formatting helper

private extension Date {
    /// Formats a date as `yyyy-MM-dd` for use in calendar API paths.
    func calendarDateString() -> String {
        dateString(withFormat: "yyyy-MM-dd")
    }
}
