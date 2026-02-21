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

final class MovieTests: TraktTestCase {
    // MARK: - Trending

    func test_get_trending_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/trending?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_trending_movies")))

        let expectation = XCTestExpectation(description: "Get Trending Movies")
        traktManager.getTrendingMovies(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let trendingMovies, _, _) = result {
                XCTAssertEqual(trendingMovies.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Popular

    func test_get_popular_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/popular?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_popular_movies")))

        let expectation = XCTestExpectation(description: "Get Popular Movies")
        traktManager.getPopularMovies(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let popularMovies, _, _) = result {
                XCTAssertEqual(popularMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Played

    func test_get_most_played_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/played/all?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_played_movies")))

        let expectation = XCTestExpectation(description: "Get Most Played Movies")
        traktManager.getPlayedMovies(period: .all, pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let playedMovies, _, _) = result {
                XCTAssertEqual(playedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watched

    func test_get_most_watched_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/watched/all?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_watched_movies")))

        let expectation = XCTestExpectation(description: "Get Most Watched Movies")
        traktManager.getWatchedMovies(period: .all, pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let watchedMovies, _, _) = result {
                XCTAssertEqual(watchedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Collected

    func test_get_most_collected_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/collected/all?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_collected_movies")))

        let expectation = XCTestExpectation(description: "Get Most Collected Movies")
        traktManager.getCollectedMovies(period: .all, pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let collectedMovies, _, _) = result {
                XCTAssertEqual(collectedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Anticipated

    func test_get_most_anticipated_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/anticipated?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_anticipated_movies")))

        let expectation = XCTestExpectation(description: "Get Most Anticipated Movies")
        traktManager.getAnticipatedMovies(pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let anticipatedMovies, _, _) = result {
                XCTAssertEqual(anticipatedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Box Office

    func test_get_weekend_box_office() throws {
        try mock(.GET, "https://api.trakt.tv/movies/boxoffice?extended=min", result: .success(jsonData(named: "test_get_weekend_box_office")))

        let expectation = XCTestExpectation(description: "Get Weekend Box Office")
        traktManager.getWeekendBoxOffice { result in
            if case .success(let boxOffice) = result {
                XCTAssertEqual(boxOffice.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Updates

    func test_get_recently_updated_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/updates/2014-01-10?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_recently_updated_movies")))

        let expectation = XCTestExpectation(description: "Get recently updated movies")
        traktManager.getUpdatedMovies(startDate: try? Date.dateFromString("2014-01-10"), pagination: Pagination(page: 1, limit: 10)) { result in
            if case .success(let updatedMovies, _, _) = result {
                XCTAssertEqual(updatedMovies.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Summary

    func test_get_min_movie() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010?extended=min", result: .success(jsonData(named: "Movie_Min")))

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

        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    func test_get_full_movie() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010?extended=full", result: .success(jsonData(named: "Movie_Full")))

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

        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Aliases

    func test_get_movie_aliases() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/aliases", result: .success(jsonData(named: "test_get_movie_aliases")))

        let expectation = XCTestExpectation(description: "Get movie aliases")
        traktManager.getMovieAliases(movieID: "tron-legacy-2010") { result in
            if case .success(let aliases) = result {
                XCTAssertEqual(aliases.count, 15)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Releases

    func test_get_movie_releases() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/releases/us", result: .success(jsonData(named: "test_get_movie_releases")))

        let expectation = XCTestExpectation(description: "Get movie releases")
        traktManager.getMovieReleases(movieID: "tron-legacy-2010", country: "us") { result in
            if case .success(let releases) = result {
                XCTAssertEqual(releases.count, 13)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Translations

    func test_get_movie_translations() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/translations/us", result: .success(jsonData(named: "test_get_movie_translations")))

        let expectation = XCTestExpectation(description: "Get movie translations")
        traktManager.getMovieTranslations(movieID: "tron-legacy-2010", language: "us") { result in
            if case .success(let translations) = result {
                XCTAssertEqual(translations.count, 3)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Comments

    func test_get_movie_comments() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/comments", result: .success(jsonData(named: "test_get_movie_comments")))

        let expectation = XCTestExpectation(description: "Get movie comments")
        traktManager.getMovieComments(movieID: "tron-legacy-2010") { result in
            if case .success(let comments, _, _) = result {
                XCTAssertEqual(comments.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Lists

    func test_get_lists_containing_movie() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/lists", result: .success(jsonData(named: "test_get_lists_containing_movie")))

        let expectation = XCTestExpectation(description: "Get lists containing movie")
        traktManager.getListsContainingMovie(movieID: "tron-legacy-2010") { result in
            if case .success(let lists, _, _) = result {
                XCTAssertEqual(lists.count, 1)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - People

    func test_get_cast_and_crew() throws {
        try mock(.GET, "https://api.trakt.tv/movies/iron-man-2008/people?extended=min", result: .success(jsonData(named: "test_get_cast_and_crew")))

        let expectation = XCTestExpectation(description: "Get movie cast and crew")
        traktManager.getPeopleInMovie(movieID: "iron-man-2008") { result in
            if case .success(let castAndCrew) = result {
                XCTAssertEqual(castAndCrew.cast?.count, 65)
                XCTAssertEqual(castAndCrew.crew?.count, 118)
                XCTAssertEqual(castAndCrew.editors?.count, 4)
                XCTAssertEqual(castAndCrew.producers?.count, 19)
                XCTAssertEqual(castAndCrew.camera?.count, 3)
                XCTAssertEqual(castAndCrew.art?.count, 11)
                XCTAssertEqual(castAndCrew.sound?.count, 12)
                XCTAssertEqual(castAndCrew.costume?.count, 2)
                XCTAssertEqual(castAndCrew.writers?.count, 8)
                XCTAssertEqual(castAndCrew.visualEffects?.count, 7)
                XCTAssertEqual(castAndCrew.directors?.count, 6)
                XCTAssertEqual(castAndCrew.lighting?.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Ratings

    func test_get_movie_ratings() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/ratings", result: .success(jsonData(named: "test_get_movie_ratings")))

        let expectation = XCTestExpectation(description: "Get movie ratings")
        traktManager.getMovieRatings(movieID: "tron-legacy-2010") { result in
            if case .success(let ratings) = result {
                XCTAssertEqual(ratings.rating, 7.3377800000000004)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Related

    func test_get_related_movies() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/related?extended=min", result: .success(jsonData(named: "test_get_related_movies")))

        let expectation = XCTestExpectation(description: "Get related movies")
        traktManager.getRelatedMovies(movieID: "tron-legacy-2010") { result in
            if case .success(let relatedMovies) = result {
                XCTAssertEqual(relatedMovies.count, 10)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - stats

    func test_get_movie_stats() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/stats", result: .success(jsonData(named: "test_get_movie_stats")))

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
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }

    // MARK: - Watching

    func test_get_users_watching_movie_now() throws {
        try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/watching", result: .success(jsonData(named: "test_get_users_watching_movie_now")))

        let expectation = XCTestExpectation(description: "Get users watching a movie")
        traktManager.getUsersWatchingMovie(movieID: "tron-legacy-2010") { result in
            if case .success(let users) = result {
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        
        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
