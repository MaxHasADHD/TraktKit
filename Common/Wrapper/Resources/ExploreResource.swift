//
//  ExploreResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ExploreResource: Sendable {

    // MARK: - Properties
    
    public let trending = Trending()
    public let popular = Popular()
    public let recommended = Recommended()
    public let played = Played()
    public let watched = Watched()
    public let collected = Collected()
    public let anticipated = Anticipated()

    // MARK: - Routes

    public struct Trending: Sendable {
        public func shows() -> Route<PagedObject<[TraktTrendingShow]>> {
            Route(path: "shows/trending", method: .GET)
        }

        public func movies() -> Route<[TraktTrendingMovie]> {
            Route(path: "movies/trending", method: .GET)
        }
    }
    
    public struct Popular: Sendable {
        public func shows() -> Route<[TraktShow]> {
            Route(path: "shows/popular", method: .GET)
        }
        
        public func movies() -> Route<[TraktMovie]> {
            Route(path: "movies/popular", method: .GET)
        }
    }
    
    public struct Recommended: Sendable {
        public func shows() -> Route<[TraktTrendingShow]> {
            Route(path: "shows/recommended", method: .GET)
        }
        
        public func movies() -> Route<[TraktTrendingMovie]> {
            Route(path: "movies/recommended", method: .GET)
        }
    }
    
    public struct Played: Sendable {
        public func shows() -> Route<[TraktMostShow]> {
            Route(path: "shows/played", method: .GET)
        }
        
        public func movies() -> Route<[TraktMostMovie]> {
            Route(path: "movies/played", method: .GET)
        }
    }
    
    public struct Watched: Sendable {
        public func shows() -> Route<[TraktMostShow]> {
            Route(path: "shows/watched", method: .GET)
        }
        
        public func movies() -> Route<[TraktMostMovie]> {
            Route(path: "movies/watched", method: .GET)
        }
    }
    
    public struct Collected: Sendable {
        public func shows() -> Route<[TraktTrendingShow]> {
            Route(path: "shows/collected", method: .GET)
        }
        
        public func movies() -> Route<[TraktTrendingMovie]> {
            Route(path: "movies/collected", method: .GET)
        }
    }

    public struct Anticipated: Sendable {
        public func shows() -> Route<[TraktAnticipatedShow]> {
            Route(path: "shows/anticipated", method: .GET)
        }
        
        public func movies() -> Route<[TraktAnticipatedMovie]> {
            Route(path: "movies/anticipated", method: .GET)
        }
    }
}
