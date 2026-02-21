//
//  LanguagesResource.swift
//  TraktKit
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /// Endpoints for the Languages group.
    public struct LanguagesResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Get a list of all languages, including names and codes.

         **Endpoint:** `GET /languages/{type}`

         - parameter type: The media type to retrieve languages for (`movies` or `shows`).
         */
        public func list(type: WatchedType) -> Route<[Languages]> {
            Route(path: "languages/\(type)", method: .GET, traktManager: traktManager)
        }
    }
}
