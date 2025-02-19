//
//  SearchResource.swift
//
//
//  Created by Maximilian Litteral on 10/2/22.
//

import Foundation

public struct SearchResource {
    
    // MARK: - Actions
    
    public func search(
        _ query: String,
        types: [SearchType]// = [.movie, .show, .episode, .person, .list]
    ) -> Route<[TraktSearchResult]> {
        let searchTypes = types.map { $0.rawValue }.joined(separator: ",")
        return Route(path: "search/\(searchTypes)", method: .GET).query(query)
    }
    
    public func lookup(_ id: LookupType) -> Route<[TraktSearchResult]> {
        Route(path: "search/\(id.name)/\(id.id)", method: .GET)
    }
}
