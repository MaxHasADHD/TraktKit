//
//  MoviesTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

import Testing
import Foundation
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct MoviesTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        @Test func getTrendingMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/trending?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_trending_movies")), headers: [.page(1), .pageCount(10)])

            let result = try await traktManager.movies
                .trending()
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()
            let (movies, currentPage, pageCount) = (result.object, result.currentPage, result.pageCount)
            #expect(movies.count == 2)
            #expect(currentPage == 1)
            #expect(pageCount == 10)
        }

        @Test func getPopularMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/popular?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_popular_movies")))

            let result = try await traktManager.movies
                .popular()
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()
            let (movies, _, _) = (result.object, result.currentPage, result.pageCount)
            #expect(movies.count == 10)
        }

        @Test func getMostPlayedMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/played/all?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_played_movies")))

            let result = try await traktManager.movies
                .played(period: .all)
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()
            let (movies, _, _) = (result.object, result.currentPage, result.pageCount)
            #expect(movies.count == 10)
        }

        @Test func getMostWatchedMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/watched/all?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_watched_movies")))

            let result = try await traktManager.movies
                .watched(period: .all)
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()
            let (movies, _, _) = (result.object, result.currentPage, result.pageCount)
            #expect(movies.count == 10)
        }

        @Test func getPeopleInMovie() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/iron-man-2008/people?extended=min", result: .success(jsonData(named: "test_get_cast_and_crew")))

            let castAndCrew = try await traktManager.movie(id: "iron-man-2008")
                .people()
                .extend(.Min)
                .perform()

            #expect(castAndCrew.cast?.count == 65)
            #expect(castAndCrew.crew?.count == 118)
            #expect(castAndCrew.editors?.count == 4)
            #expect(castAndCrew.producers?.count == 19)
            #expect(castAndCrew.camera?.count == 3)
            #expect(castAndCrew.art?.count == 11)
            #expect(castAndCrew.sound?.count == 12)
            #expect(castAndCrew.costume?.count == 2)
            #expect(castAndCrew.writers?.count == 8)
            #expect(castAndCrew.visualEffects?.count == 7)
            #expect(castAndCrew.directors?.count == 6)
            #expect(castAndCrew.lighting?.count == 2)
        }

        @Test func getMovieStudios() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/studios", result: .success(jsonData(named: "test_get_movie_studios")))

            let studios = try await traktManager.movie(id: "tron-legacy-2010")
                .studios()
                .perform()

            #expect(studios.count == 5)
        }

        // MARK: - MoviesResource Additional Tests

        @Test func getFavoritedMoviesDefaultPeriod() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/favorited?page=1&limit=10", result: .success(jsonData(named: "test_get_most_favorited_movies")))

            let result = try await traktManager.movies
                .favorited()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 3)
        }

        @Test func getFavoritedMoviesWithPeriod() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/favorited/monthly?page=1&limit=10", result: .success(jsonData(named: "test_get_most_favorited_movies")))

            let result = try await traktManager.movies
                .favorited(period: .monthly)
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 3)
        }

        @Test func getCollectedMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/collected/all?page=1&limit=10", result: .success(jsonData(named: "test_get_most_watched_movies")))

            let result = try await traktManager.movies
                .collected(period: .all)
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 10)
        }

        @Test func getAnticipatedMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/anticipated?page=1&limit=10", result: .success(jsonData(named: "test_get_most_anticipated_movies")))

            let result = try await traktManager.movies
                .anticipated()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 10)
        }

        @Test func getBoxOfficeMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/boxoffice", result: .success(jsonData(named: "test_get_box_office_movies")))

            let movies = try await traktManager.movies
                .boxOffice()
                .perform()

            #expect(movies.count == 10)
        }

        @Test func getRecentlyUpdatedMovies() async throws {
            let startDate = Date(timeIntervalSince1970: 1411416000) // 2014-09-22T20:00:00Z
            let formattedDate = "2014-09-22T20:00:00"
            try await suite.mock(.GET, "https://api.trakt.tv/movies/updates/\(formattedDate)?page=1&limit=10", result: .success(jsonData(named: "test_get_recently_updated_movies")))

            let result = try await traktManager.movies
                .recentlyUpdated(since: startDate)
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 2)
        }

        @Test func getRecentlyUpdatedMovieIds() async throws {
            let startDate = Date(timeIntervalSince1970: 1411416000) // 2014-09-22T20:00:00Z
            let formattedDate = "2014-09-22T20:00:00"
            try await suite.mock(.GET, "https://api.trakt.tv/movies/updates/id/\(formattedDate)?page=1&limit=10", result: .success(jsonData(named: "test_get_recently_updated_movie_ids")))

            let result = try await traktManager.movies
                .recentlyUpdatedIds(since: startDate)
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 6)
        }

        // MARK: - MovieResource Additional Tests

        @Test func getMovieSummaryMin() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010?extended=min", result: .success(jsonData(named: "Movie_Min")))

            let movie = try await traktManager.movie(id: "tron-legacy-2010")
                .summary()
                .extend(.Min)
                .perform()

            #expect(movie.title == "TRON: Legacy")
            #expect(movie.tagline == nil)
        }

        @Test func getMovieSummaryFull() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010?extended=full", result: .success(jsonData(named: "Movie_Full")))

            let movie = try await traktManager.movie(id: "tron-legacy-2010")
                .summary()
                .extend(.Full)
                .perform()

            #expect(movie.title == "TRON: Legacy")
            #expect(movie.tagline == "The Game Has Changed.")
        }

        @Test func getMovieAliases() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/aliases", result: .success(jsonData(named: "test_get_movie_aliases")))

            let aliases = try await traktManager.movie(id: "tron-legacy-2010")
                .aliases()
                .perform()

            #expect(aliases.count == 15)
        }

        @Test func getMovieReleasesAllCountries() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/releases", result: .success(jsonData(named: "test_get_movie_releases")))

            let releases = try await traktManager.movie(id: "tron-legacy-2010")
                .releases()
                .perform()

            #expect(releases.count == 13)
        }

        @Test func getMovieReleasesSpecificCountry() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/releases/us", result: .success(jsonData(named: "test_get_movie_releases")))

            let releases = try await traktManager.movie(id: "tron-legacy-2010")
                .releases(country: "us")
                .perform()

            #expect(releases.count == 13)
        }

        @Test func getMovieTranslationsAll() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/translations", result: .success(jsonData(named: "test_get_movie_translations")))

            let translations = try await traktManager.movie(id: "tron-legacy-2010")
                .translations()
                .perform()

            #expect(translations.count == 3)
        }

        @Test func getMovieTranslationsSpecificLanguage() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/translations/es", result: .success(jsonData(named: "test_get_movie_translations")))

            let translations = try await traktManager.movie(id: "tron-legacy-2010")
                .translations(language: "es")
                .perform()

            #expect(translations.count == 3)
        }

        @Test func getMovieCommentsDefault() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/comments?page=1&limit=10", result: .success(jsonData(named: "test_get_movie_comments")))

            let result = try await traktManager.movie(id: "tron-legacy-2010")
                .comments()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 1)
        }

        @Test func getMovieCommentsWithSort() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/comments/likes?page=1&limit=10", result: .success(jsonData(named: "test_get_movie_comments")))

            let result = try await traktManager.movie(id: "tron-legacy-2010")
                .comments(sort: "likes")
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 1)
        }

        @Test func getMovieContainingLists() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/lists?page=1&limit=10", result: .success(jsonData(named: "test_get_lists_containing_movie")))

            let result = try await traktManager.movie(id: "tron-legacy-2010")
                .containingLists()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 1)
        }

        @Test func getMovieContainingListsWithTypeAndSort() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/lists/personal/popular?page=1&limit=10", result: .success(jsonData(named: "test_get_lists_containing_movie")))

            let result = try await traktManager.movie(id: "tron-legacy-2010")
                .containingLists(type: "personal", sort: "popular")
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 1)
        }

        @Test func getMovieRatings() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/ratings", result: .success(jsonData(named: "test_get_movie_ratings")))

            let ratings = try await traktManager.movie(id: "tron-legacy-2010")
                .ratings()
                .perform()

            #expect(ratings.rating == 7.33778)
        }

        @Test func getRelatedMovies() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/related?page=1&limit=10", result: .success(jsonData(named: "test_get_related_movies")))

            let result = try await traktManager.movie(id: "tron-legacy-2010")
                .relatedMovies()
                .page(1)
                .limit(10)
                .perform()

            #expect(result.object.count == 10)
        }

        @Test func getMovieStats() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/stats", result: .success(jsonData(named: "test_get_movie_stats")))

            let stats = try await traktManager.movie(id: "tron-legacy-2010")
                .stats()
                .perform()

            #expect(stats.watchers == 39204)
        }

        @Test func getUsersWatchingMovie() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/watching", result: .success(jsonData(named: "test_get_users_watching_movie_now")))

            let users = try await traktManager.movie(id: "tron-legacy-2010")
                .usersWatching()
                .perform()

            #expect(users.count >= 0)
        }

        @Test func getMovieVideos() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/videos", result: .success(Data("[]".utf8)))

            let videos = try await traktManager.movie(id: "tron-legacy-2010")
                .videos()
                .perform()

            #expect(videos.count == 0)
        }

        @Test func movieResourceWithTraktId() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/12345?extended=min", result: .success(jsonData(named: "Movie_Min")))

            let movie = try await traktManager.movie(id: 12345)
                .summary()
                .extend(.Min)
                .perform()

            #expect(movie.title == "TRON: Legacy")
        }

        @Test func movieResourceWithSlug() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010?extended=min", result: .success(jsonData(named: "Movie_Min")))

            let movie = try await traktManager.movie(id: "tron-legacy-2010")
                .summary()
                .extend(.Min)
                .perform()

            #expect(movie.title == "TRON: Legacy")
        }

        @Test func movieResourceWithIMDBId() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tt1104001?extended=min", result: .success(jsonData(named: "Movie_Min")))

            let movie = try await traktManager.movie(id: "tt1104001")
                .summary()
                .extend(.Min)
                .perform()

            #expect(movie.title == "TRON: Legacy")
        }

        @Test func refreshMovieMetadata() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/refresh", result: .success(Data()))

            try await traktManager.movie(id: "tron-legacy-2010")
                .refreshMetadata()
                .perform()

            // Test passes if no error is thrown - refreshMetadata is a VIP-only endpoint
            // that queues metadata refresh and returns empty response
        }
    }
}
