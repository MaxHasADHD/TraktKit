//
//  ListItemsReorderResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/20/26.
//

import Foundation

public struct ListItemsReorderResult: TraktObject {
    public let updated: Int
    public let skippedIds: [Int]
    public let list: List

    public struct List: TraktObject {
        public let updatedAt: Date
        public let itemCount: Int

        enum CodingKeys: String, CodingKey {
            case updatedAt = "updated_at"
            case itemCount = "item_count"
        }
    }

    enum CodingKeys: String, CodingKey {
        case updated
        case skippedIds = "skipped_ids"
        case list
    }
}
