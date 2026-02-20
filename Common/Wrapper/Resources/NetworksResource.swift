//
//  NetworksResource.swift
//  TraktKit
//

import Foundation

extension TraktManager {
    /// Endpoints for the Networks group.
    public struct NetworksResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Get a list of all TV networks, including the `name`, `country`, and `ids`.

         Most TV shows have a TV network where it originally aired. Some API methods allow filtering by network, so it's good to cache this list in your app.

         📄 Pagination Optional
         */
        public func list() -> Route<[TraktStudio]> {
            Route(path: "networks", method: .GET, traktManager: traktManager)
        }
    }
}
