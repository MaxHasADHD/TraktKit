//
//  ShowResource.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ShowResource {

    // MARK: - Properties

    public let id: CustomStringConvertible
    public let traktManager: TraktManager

    // MARK: - Lifecycle

    public init(id: CustomStringConvertible, traktManager: TraktManager = .sharedManager) {
        self.id = id
        self.traktManager = traktManager
    }

    // MARK: - Methods

    public func summary() async throws -> Route<TraktShow> {
        try await traktManager.get("shows/\(id)")
    }

    public func aliases() async throws -> Route<[Alias]> {
        Route(path: "shows/\(id)/aliases", method: .GET, traktManager: traktManager)
    }

    public func certifications() async throws -> Route<Certifications> {
        Route(path: "shows/\(id)/certifications", method: .GET, traktManager: traktManager)
    }

    // MARK: - Resources

    public func season(_ number: Int) -> SeasonResource {
        SeasonResource(showId: id, seasonNumber: number, traktManager: traktManager)
    }
}
