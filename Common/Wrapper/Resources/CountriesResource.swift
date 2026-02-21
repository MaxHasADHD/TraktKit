//
//  CountriesResource.swift
//  TraktKit
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /// Endpoints for the Countries group.
    public struct CountriesResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Get a list of all countries, including names and codes.

         - parameter type: The media type to retrieve countries for (`movies` or `shows`).
         */
        public func list(type: WatchedType) -> Route<[Languages]> {
            Route(path: "countries/\(type)", method: .GET, traktManager: traktManager)
        }
    }
}
