//
//  SearchResource.swift
//
//
//  Created by Maximilian Litteral on 10/2/22.
//

import Foundation
import SwiftAPIClient

public struct SearchResource {

    private let traktManager: TraktManager

    internal init(traktManager: TraktManager) {
        self.traktManager = traktManager
    }

    // MARK: - Actions
    
    /**
     Search for movies, shows, episodes, people, and lists.

     **Endpoint:** `GET /search/{types}`

     - parameter query: The search query string.
     - parameter types: Media types to search (movie, show, episode, person, list).
     */
    public func search(
        _ query: String,
        types: [SearchType]// = [.movie, .show, .episode, .person, .list]
    ) -> Route<[TraktSearchResult]> {
        let searchTypes = types.map { $0.rawValue }.joined(separator: ",")
        return Route(path: "search/\(searchTypes)", method: .GET, traktManager: traktManager).query(query)
    }
    
    /**
     Get an item by its ID.

     **Endpoint:** `GET /search/{id_type}/{id}`

     - parameter id: The lookup type and ID (e.g., IMDB, TMDB, TVDB).
     */
    public func lookup(_ id: LookupType) -> Route<[TraktSearchResult]> {
        Route(path: "search/\(id.name)/\(id.id)", method: .GET, traktManager: traktManager)
    }
}
