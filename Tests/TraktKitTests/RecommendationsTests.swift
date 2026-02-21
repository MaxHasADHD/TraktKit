//
//  RecommendationsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/29/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Recommendations Tests")
    struct RecommendationsTests {
        let traktManager: TraktManager
        
        init() async throws {
            self.traktManager = await authenticatedTraktManager()
        }
        
        // MARK: - Movies
        
        @Test func getMovieRecommendations() async throws {
            try mock(.GET, "https://api.trakt.tv/recommendations/movies", result: .success(jsonData(named: "test_get_movie_recommendations")))
            
            let movies = try await traktManager.recommendations
                .movies()
                .perform()
            
            #expect(movies.count == 10)
        }
        
        // MARK: - Hide Movie
        
        @Test func hideMovieRecommendation() async throws {
            try mock(.DELETE, "https://api.trakt.tv/recommendations/movies/922", result: .success(.init()))
            
            try await traktManager.recommendations
                .hideMovie(id: 922)
                .perform()
        }
        
        // MARK: - Shows
        
        @Test func getShowRecommendations() async throws {
            try mock(.GET, "https://api.trakt.tv/recommendations/shows", result: .success(jsonData(named: "test_get_show_recommendations")))
            
            let shows = try await traktManager.recommendations
                .shows()
                .perform()
            
            #expect(shows.count == 10)
        }
        
        // MARK: - Hide Show
        
        @Test func hideShowRecommendation() async throws {
            try mock(.DELETE, "https://api.trakt.tv/recommendations/shows/922", result: .success(.init()))
            
            try await traktManager.recommendations
                .hideShow(id: 922)
                .perform()
        }
    }
}
