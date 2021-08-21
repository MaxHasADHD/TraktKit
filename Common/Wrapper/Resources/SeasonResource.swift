//
//  SeasonResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

@available(macOS 12.0, iOS 15.0, *)
public struct SeasonResource {
    public let showId: CustomStringConvertible
    public let seasonNumber: Int
    public let traktManager: TraktManager

    init(showId: CustomStringConvertible, seasonNumber: Int, traktManager: TraktManager = .sharedManager) {
        self.showId = showId
        self.seasonNumber = seasonNumber
        self.traktManager = traktManager
    }

    public func summary() async throws -> Route<TraktSeason> {
        try await traktManager.get("shows/\(showId)/seasons/\(seasonNumber)")
    }

    public func comments() async throws -> Route<[Comment]> {
        try await traktManager.get("shows/\(showId)/seasons/\(seasonNumber)/comments")
    }
}
