//
//  MovieTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class MovieTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }
    
    // MARK: - Trending

    func test_get_trending_movies() {
        session.nextData = jsonData(named: "test_get_trending_movies")

        let expectation = XCTestExpectation(description: "Get Trending Movies")
        traktManager.getTrendingMovies(page: 1, limit: 10) { result in
            if case .success(let trendingMovies) = result {
                XCTAssertEqual(trendingMovies.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/trending?page=1&limit=10&extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Popular

    func test_get_popular_movies() {
        session.nextData = jsonData(named: "test_get_popular_movies")

        let expectation = XCTestExpectation(description: "Get Popular Movies")
        traktManager.getPopularMovies(page: 1, limit: 10) { result in
            if case .success(let popularMovies) = result {
                XCTAssertEqual(popularMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/popular?page=1&limit=10&extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Played

    func test_get_most_played_movies() {
        session.nextData = jsonData(named: "test_get_most_played_movies")

        let expectation = XCTestExpectation(description: "Get Most Played Movies")
        traktManager.getPlayedMovies(page: 1, limit: 10, period: .All) { result in
            if case .success(let playedMovies) = result {
                XCTAssertEqual(playedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/played/all?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watched

    func test_get_most_watched_movies() {
        session.nextData = jsonData(named: "test_get_most_watched_movies")

        let expectation = XCTestExpectation(description: "Get Most Watched Movies")
        traktManager.getWatchedMovies(page: 1, limit: 10, period: .All) { result in
            if case .success(let watchedMovies) = result {
                XCTAssertEqual(watchedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/watched/all?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Collected

    func test_get_most_collected_movies() {
        session.nextData = jsonData(named: "test_get_most_collected_movies")

        let expectation = XCTestExpectation(description: "Get Most Collected Movies")
        traktManager.getCollectedMovies(page: 1, limit: 10, period: .All) { result in
            if case .success(let collectedMovies) = result {
                XCTAssertEqual(collectedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/collected/all?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Anticipated

    func test_get_most_anticipated_movies() {
        session.nextData = jsonData(named: "test_get_most_anticipated_movies")

        let expectation = XCTestExpectation(description: "Get Most Anticipated Movies")
        traktManager.getAnticipatedMovies(page: 1, limit: 10) { result in
            if case .success(let anticipatedMovies) = result {
                XCTAssertEqual(anticipatedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/anticipated?page=1&limit=10&extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Box Office

    func test_get_weekend_box_office() {
        session.nextData = jsonData(named: "test_get_weekend_box_office")

        let expectation = XCTestExpectation(description: "Get Weekend Box Office")
        traktManager.getWeekendBoxOffice { result in
            if case .success(let boxOffice) = result {
                XCTAssertEqual(boxOffice.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/boxoffice?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Updates

    func test_get_recently_updated_movies() {
        session.nextData = jsonData(named: "test_get_recently_updated_movies")

        let expectation = XCTestExpectation(description: "Get recently updated movies")
        traktManager.getUpdatedMovies(page: 1, limit: 10, startDate: try? Date.dateFromString("2014-01-10")) { result in
            if case .success(let updatedMovies) = result {
                XCTAssertEqual(updatedMovies.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/updates/2014-01-10?page=1&limit=10")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Summary

    func test_get_min_movie() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Movie_Min")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "MovieSummary")
        traktManager.getMovieSummary(movieID: "tron-legacy-2010") { result in
            if case .success(let movie) = result {
                XCTAssertEqual(movie.title, "TRON: Legacy")
                XCTAssertEqual(movie.year, 2010)
                XCTAssertEqual(movie.ids.trakt, 1)
                XCTAssertEqual(movie.ids.slug, "tron-legacy-2010")
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_movie() {
        let session = MockURLSession()
        session.nextData = jsonData(named: "Movie_Full")
        let traktManager = TraktManager(session: session)

        let expectation = XCTestExpectation(description: "MovieSummary")
        traktManager.getMovieSummary(movieID: "tron-legacy-2010", extended: [.Full]) { result in
            if case .success(let movie) = result {
                XCTAssertEqual(movie.title, "TRON: Legacy")
                XCTAssertEqual(movie.year, 2010)
                XCTAssertEqual(movie.ids.trakt, 343)
                XCTAssertEqual(movie.ids.slug, "tron-legacy-2010")
                XCTAssertEqual(movie.tagline, "The Game Has Changed.")
                XCTAssertNotNil(movie.overview)
                XCTAssertNotNil(movie.released)
                XCTAssertEqual(movie.runtime, 125)
                XCTAssertNotNil(movie.updatedAt)
                XCTAssertNil(movie.trailer)
                XCTAssertEqual(movie.homepage?.absoluteString, "http://disney.go.com/tron/")
                XCTAssertEqual(movie.language, "en")
                XCTAssertEqual(movie.availableTranslations!, ["en"])
                XCTAssertEqual(movie.genres!, ["action"])
                XCTAssertEqual(movie.certification, "PG-13")
            }
            expectation.fulfill()
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010?extended=full")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Aliases

    func test_get_movie_aliases() {
        session.nextData = jsonData(named: "test_get_movie_aliases")

        let expectation = XCTestExpectation(description: "Get movie aliases")
        traktManager.getMovieAliases(movieID: "tron-legacy-2010") { result in
            if case .success(let aliases) = result {
                XCTAssertEqual(aliases.count, 15)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/aliases")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Releases

    func test_get_movie_releases() {
        session.nextData = jsonData(named: "test_get_movie_releases")

        let expectation = XCTestExpectation(description: "Get movie releases")
        traktManager.getMovieReleases(movieID: "tron-legacy-2010", country: "us") { result in
            if case .success(let releases) = result {
                XCTAssertEqual(releases.count, 13)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/releases/us")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Translations

    func test_get_movie_translations() {
        session.nextData = jsonData(named: "test_get_movie_translations")

        let expectation = XCTestExpectation(description: "Get movie translations")
        traktManager.getMovieTranslations(movieID: "tron-legacy-2010", language: "us") { result in
            if case .success(let translations) = result {
                XCTAssertEqual(translations.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/translations/us")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comments

    func test_get_movie_comments() {
        session.nextData = jsonData(named: "test_get_movie_comments")

        let expectation = XCTestExpectation(description: "Get movie comments")
        traktManager.getMovieComments(movieID: "tron-legacy-2010") { result in
            if case .success(let comments) = result {
                XCTAssertEqual(comments.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/comments")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_lists_containing_movie() {
        XCTFail("Need to implement")
    }

    // MARK: - People

    func test_get_cast_and_crew() {
        session.nextData = jsonData(named: "test_get_cast_and_crew")

        let expectation = XCTestExpectation(description: "Get movie cast and crew")
        traktManager.getPeopleInMovie(movieID: "tron-legacy-2010") { result in
            if case .success(let castAndCrew) = result {
                XCTAssertEqual(castAndCrew.writers?.count, 4)
                XCTAssertEqual(castAndCrew.directors?.count, 1)
                XCTAssertEqual(castAndCrew.cast?.count, 18)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/people?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Ratings

    func test_get_movie_ratings() {
        session.nextData = jsonData(named: "test_get_movie_ratings")

        let expectation = XCTestExpectation(description: "Get movie ratings")
        traktManager.getMovieRatings(movieID: "tron-legacy-2010") { result in
            if case .success(let ratings) = result {
                XCTAssertEqual(ratings.rating, 7.3377800000000004)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/ratings")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Related

    func test_get_related_movies() {
        session.nextData = jsonData(named: "test_get_related_movies")

        let expectation = XCTestExpectation(description: "Get related movies")
        traktManager.getRelatedMovies(movieID: "tron-legacy-2010") { result in
            if case .success(let relatedMovies) = result {
                XCTAssertEqual(relatedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/related?extended=min")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - stats

    func test_get_movie_stats() {
        session.nextData = jsonData(named: "test_get_movie_stats")

        let expectation = XCTestExpectation(description: "Get movies stats")
        traktManager.getMovieStatistics(movieID: "tron-legacy-2010") { result in
            if case .success(let movieStats) = result {
                XCTAssertEqual(movieStats.comments, 36)
                XCTAssertEqual(movieStats.lists, 4561)
                XCTAssertEqual(movieStats.votes, 7866)
                XCTAssertEqual(movieStats.watchers, 39204)
                XCTAssertEqual(movieStats.plays, 51033)
                XCTAssertEqual(movieStats.collectors, 27379)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/stats")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watching

    func test_get_users_watching_movie_now() {
        session.nextData = jsonData(named: "test_get_users_watching_movie_now")

        let expectation = XCTestExpectation(description: "Get users watching a movie")
        traktManager.getUsersWatchingMovie(movieID: "tron-legacy-2010") { result in
            if case .success(let users) = result {
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/movies/tron-legacy-2010/watching")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
