//
//  TraktMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktMovie: Codable {
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let tagline: String?
    public let overview: String?
    public let released: Date?
    public let runtime: Int?
    public let trailer: URL?
    public let homepage: URL?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: Date?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let certification: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case year
        case ids
        
        case tagline
        case overview
        case released
        case runtime
        case trailer
        case homepage
        case rating
        case votes
        case updatedAt = "updated_at"
        case language
        case availableTranslations = "available_translations"
        case genres
        case certification
    }
}
