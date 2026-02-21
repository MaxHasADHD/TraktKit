//
//  SavedFilter.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/18/25.
//

import Foundation

public struct SavedFilter: TraktObject {
    public let rank: Int
    public let id: Int
    public let section: String
    public let name: String
    public let path: String
    public let query: String
    public let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case rank
        case id
        case section
        case name
        case path
        case query
        case updatedAt = "updated_at"
    }
}
