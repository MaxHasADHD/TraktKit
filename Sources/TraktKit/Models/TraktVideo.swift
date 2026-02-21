//
//  TraktVideo.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/9/25.
//

import Foundation

public struct TraktVideo: TraktObject {
    public let title: String
    public let url: String
    public let site: String
    public let type: String
    public let size: Int
    public let official: Bool
    public let publishedAt: Date
    public let country: String
    public let language: String

    enum CodingKeys: String, CodingKey {
        case title
        case url
        case site
        case type
        case size
        case official
        case publishedAt = "published_at"
        case country
        case language
    }
}
