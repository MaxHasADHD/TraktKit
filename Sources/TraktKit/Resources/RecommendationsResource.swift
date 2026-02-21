//
//  RecommendationsResource.swift
//  TraktKit
//

import Foundation
import SwiftAPIClient

extension TraktManager {
    /**
     Trakt recommendations are built on top of your viewing activity and preferences. The more you watch, the better your recommendations will be.
     */
    public struct RecommendationsResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Movies

        /**
         Movie recommendations for a user. By default, `10` results are returned. You can send a `limit` to get up to `100` results per page.

         Set `ignoreCollected=true` to filter out movies the user has already collected or `ignoreWatchlisted=true` to filter out movies the user has already watchlisted.

         The `favorited_by` array contains all users who favorited the item along with any notes they added.

         **Endpoint:** `GET /recommendations/movies`

         🔒 OAuth Required • ✨ Extended Info

         - parameter ignoreCollected: Filter out movies the user has already collected.
         - parameter ignoreWatchlisted: Filter out movies the user has already watchlisted.
         */
        public func movies(ignoreCollected: Bool? = nil, ignoreWatchlisted: Bool? = nil) -> Route<[TraktMovie]> {
            var queryItems: [String: String] = [:]
            if let ignoreCollected { queryItems["ignore_collected"] = ignoreCollected ? "true" : "false" }
            if let ignoreWatchlisted { queryItems["ignore_watchlisted"] = ignoreWatchlisted ? "true" : "false" }
            return Route(path: "recommendations/movies", queryItems: queryItems, method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Hide a movie from getting recommended anymore.

         **Endpoint:** `DELETE /recommendations/movies/{id}`

         🔒 OAuth Required

         - parameter id: Trakt ID, Trakt slug, or IMDB ID.
         */
        public func hideMovie(id: CustomStringConvertible) -> EmptyRoute {
            EmptyRoute(paths: ["recommendations/movies", id], method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }

        // MARK: - Shows

        /**
         TV show recommendations for a user. By default, `10` results are returned. You can send a `limit` to get up to `100` results per page.

         Set `ignoreCollected=true` to filter out shows the user has already collected or `ignoreWatchlisted=true` to filter out shows the user has already watchlisted.

         The `favorited_by` array contains all users who favorited the item along with any notes they added.

         **Endpoint:** `GET /recommendations/shows`

         🔒 OAuth Required • ✨ Extended Info

         - parameter ignoreCollected: Filter out shows the user has already collected.
         - parameter ignoreWatchlisted: Filter out shows the user has already watchlisted.
         */
        public func shows(ignoreCollected: Bool? = nil, ignoreWatchlisted: Bool? = nil) -> Route<[TraktShow]> {
            var queryItems: [String: String] = [:]
            if let ignoreCollected { queryItems["ignore_collected"] = ignoreCollected ? "true" : "false" }
            if let ignoreWatchlisted { queryItems["ignore_watchlisted"] = ignoreWatchlisted ? "true" : "false" }
            return Route(path: "recommendations/shows", queryItems: queryItems, method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Hide a show from getting recommended anymore.

         **Endpoint:** `DELETE /recommendations/shows/{id}`

         🔒 OAuth Required

         - parameter id: Trakt ID, Trakt slug, or IMDB ID.
         */
        public func hideShow(id: CustomStringConvertible) -> EmptyRoute {
            EmptyRoute(paths: ["recommendations/shows", id], method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }
    }
}
