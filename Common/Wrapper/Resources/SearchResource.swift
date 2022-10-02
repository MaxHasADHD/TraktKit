//
//  File.swift
//
//
//  Created by Maximilian Litteral on 10/2/22.
//

import Foundation

public struct SearchResource {
    
    // MARK: - Properties
    
    public let traktManager: TraktManager
    
    // MARK: - Lifecycle
    
    public init(traktManager: TraktManager = .sharedManager) {
        self.traktManager = traktManager
    }
    
    // MARK: - Actions
    
    public func search(
        _ query: String,
        types: [SearchType]// = [.movie, .show, .episode, .person, .list]
    ) async throws -> Route<[TraktSearchResult]> {
        let searchTypes = types.map { $0.rawValue }.joined(separator: ",")
        return try await traktManager.get("search/\(searchTypes)", resultType: [TraktSearchResult].self).query(query)
    }
    
    public func lookup(_ id: LookupType) async throws -> Route<[TraktSearchResult]> {
        try await traktManager.get("search/\(id.name)/\(id.id)")
    }
}
