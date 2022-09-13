//
//  ExploreResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ExploreResource {
    public let traktManager: TraktManager
    public lazy var trending = Trending(traktManager: traktManager)

    public init(traktManager: TraktManager = .sharedManager) {
        self.traktManager = traktManager
    }

    public struct Trending {
        
        public let traktManager: TraktManager
        public init(traktManager: TraktManager = .sharedManager) {
            self.traktManager = traktManager
        }
        
        public func shows() -> Route<[TraktTrendingShow]> {
            Route(path: "shows/trending", method: .GET, traktManager: traktManager)
        }

        public func movies() -> Route<[TraktTrendingMovie]> {
            Route(path: "movies/trending", method: .GET, traktManager: traktManager)
        }
    }

    public func trending(_ mediaType: MediaType) -> Route<[TraktTrendingShow]> {
        Route(path: "\(mediaType)/trending", method: .GET, traktManager: traktManager)
    }

    public func popular(_ mediaType: MediaType) -> Route<[TraktShow]> {
        Route(path: "\(mediaType)/popular", method: .GET, traktManager: traktManager)
    }

    public func recommended(_ mediaType: MediaType) -> Route<[TraktTrendingShow]> {
        Route(path: "\(mediaType)/recommended", method: .GET, traktManager: traktManager)
    }

    public func played(_ mediaType: MediaType) -> Route<[TraktMostShow]> {
        Route(path: "\(mediaType)/played", method: .GET, traktManager: traktManager)
    }

    public func watched(_ mediaType: MediaType) -> Route<[TraktMostShow]> {
        Route(path: "\(mediaType)/watched", method: .GET, traktManager: traktManager)
    }

    public func collected(_ mediaType: MediaType) -> Route<[TraktTrendingShow]> {
        Route(path: "\(mediaType)/collected", method: .GET, traktManager: traktManager)
    }

    public func anticipated(_ mediaType: MediaType) -> Route<[TraktAnticipatedShow]> {
        Route(path: "\(mediaType)/anticipated", method: .GET, traktManager: traktManager)
    }
}
