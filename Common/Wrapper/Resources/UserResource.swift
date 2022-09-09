//
//  UserResource.swift
//  
//
//  Created by Maximilian Litteral on 9/9/22.
//

import Foundation

extension TraktManager {
    /// Resource for authenticated user
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    public struct CurrentUserResource {
        public let traktManager: TraktManager
        
        init(traktManager: TraktManager = .sharedManager) {
            self.traktManager = traktManager
        }
        
        // MARK: - Methods
        
        public func settings() async throws -> Route<AccountSettings> {
            try await traktManager.get("users/settings", authorized: true)
        }
    }
    
    /// Resource for /Users/id
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    public struct UsersResource {
        
        public let username: String
        public let traktManager: TraktManager
        
        init(username: String, traktManager: TraktManager = .sharedManager) {
            self.username = username
            self.traktManager = traktManager
        }
        
        // MARK: - Methods
        
        public func lists() async throws -> Route<[TraktList]> {
            try await traktManager.get("users/\(username)/lists")
        }
        
        public func itemsOnList(_ listId: String, type: ListItemType? = nil) async throws -> Route<[TraktListItem]> {
            if let type = type {
                return try await traktManager.get("users/\(username)/lists/\(listId)/items/\(type.rawValue)")
            } else {
                return try await traktManager.get("users/\(username)/lists/\(listId)/items")
            }
        }
    }
}
