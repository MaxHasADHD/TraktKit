//
//  GenresResource.swift
//  TraktKit
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /// Endpoints for the Genres group.
    public struct GenresResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Get a list of all genres, including names and slugs.

         - parameter type: The media type to retrieve genres for (`movies` or `shows`).
         */
        public func list(type: WatchedType) -> Route<[Genres]> {
            Route(path: "genres/\(type)", method: .GET, traktManager: traktManager)
        }
    }
}
