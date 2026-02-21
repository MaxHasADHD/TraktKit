//
//  CertificationsResource.swift
//  TraktKit
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /// Endpoints for the Certifications group.
    public struct CertificationsResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Get a list of all certifications, including names, slugs, and descriptions.

         Most TV shows and movies have a certification to indicate the content rating. Some API methods allow filtering by certification, so it's good to cache this list in your app.

         > note: Only `us` certifications are currently returned.

         **Endpoint:** `GET /certifications/{type}`

         - parameter type: The media type to retrieve certifications for (`movies` or `shows`).
         */
        public func list(type: WatchedType) -> Route<Certifications> {
            Route(path: "certifications/\(type)", method: .GET, traktManager: traktManager)
        }
    }
}
