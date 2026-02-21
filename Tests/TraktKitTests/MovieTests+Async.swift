//
//  MovieTests+Async.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

import Testing

extension TraktTestSuite {
    @Suite(.serialized)
    struct MovieTestSuite {
        @Test func getTrendingMovies() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/movies/trending?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_trending_movies")), headers: [.page(1), .pageCount(10)])

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
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/movies/popular?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_popular_movies")))

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
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/movies/played/all?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_played_movies")))

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
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/movies/watched/all?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_watched_movies")))

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
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/movies/iron-man-2008/people?extended=min", result: .success(jsonData(named: "test_get_cast_and_crew")))

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
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/movies/tron-legacy-2010/studios", result: .success(jsonData(named: "test_get_movie_studios")))

            let studios = try await traktManager.movie(id: "tron-legacy-2010")
                .studios()
                .perform()

            #expect(studios.count == 5)
        }
    }
}
