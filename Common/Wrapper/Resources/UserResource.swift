//
//  UserResource.swift
//  
//
//  Created by Maximilian Litteral on 9/9/22.
//

import Foundation

extension TraktManager {
    /// Resource for authenticated user
    public struct CurrentUserResource {
        // MARK: - Methods
        
        public func settings() -> Route<AccountSettings> {
            Route(path: "users/settings", method: .GET, requiresAuthentication: true)
        }

        // MARK: Following Requests

        /// List a user's pending following requests that they're waiting for the other user's to approve.
        public func getPendingFollowingRequests() -> Route<[FollowRequest]> {
            Route(path: "users/requests/following", method: .GET, requiresAuthentication: true)
        }

        /// List a user's pending follow requests so they can either approve or deny them.
        public func getFollowerRequests() -> Route<[FollowRequest]> {
            Route(path: "users/requests", method: .GET, requiresAuthentication: true)
        }

        /**
         Approve a follower using the id of the request. If the id is not found, was already approved, or was already denied, a 404 error will be returned.

         🔒 OAuth Required
         */
        public func approveFollowRequest(id: Int) -> Route<FollowResult> {
            Route(path: "users/requests/\(id)", method: .POST, requiresAuthentication: true)
        }

        /**
         Deny a follower using the id of the request. If the id is not found, was already approved, or was already denied, a 404 error will be returned.

         🔒 OAuth Required
         */
        public func denyFollowRequest(id: Int) -> EmptyRoute {
            EmptyRoute(path: "users/requests/\(id)", method: .DELETE, requiresAuthentication: true)
        }

        /**
         Get all saved filters a user has created. The path and query can be used to construct an API path to retrieve the saved data. Think of this like a dynamically updated list.

         🔥 VIP Only
         🔒 OAuth Required
         📄 Pagination
         */
        public func savedFilters(for section: String? = nil) -> Route<[SavedFilter]> {
            let path = ["users/saved_filters", section].compactMap { $0 }.joined(separator: "/")
            return Route(path: path, method: .POST, requiresAuthentication: true)
        }
    }

    /// Resource for /Users/id
    public struct UsersResource {
        public let username: String
        
        public init(username: String) {
            self.username = username
        }
        
        // MARK: - Methods

        // MARK: Settings

        public func lists() -> Route<[TraktList]> {
            Route(path: "users/\(username)/lists", method: .GET)
        }
        
        public func itemsOnList(_ listId: String, type: ListItemType? = nil) -> Route<[TraktListItem]> {
            if let type = type {
                return Route(path: "users/\(username)/lists/\(listId)/items/\(type.rawValue)", method: .GET)
            } else {
                return Route(path: "users/\(username)/lists/\(listId)/items", method: .GET)
            }
        }
    }
}
