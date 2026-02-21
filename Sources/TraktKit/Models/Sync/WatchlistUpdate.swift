//
//  WatchlistUpdate.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/2/25.
//

extension TraktManager {
    struct WatchlistUpdate: TraktObject {
        let description: String?
        let sortBy: String?
        let sortHow: String?

        enum CodingKeys: String, CodingKey {
            case description
            case sortBy = "sort_by"
            case sortHow = "sort_how"
        }
    }
}
