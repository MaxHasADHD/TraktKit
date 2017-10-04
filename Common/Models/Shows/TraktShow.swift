//
//  TraktShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Airs: Codable {
    public let day: String?
    public let time: String?
    public let timezone: String?
}

public struct TraktShow: Codable {
    
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let overview: String?
    public let firstAired: Date?
    public let airs: Airs?
    public let runtime: Int?
    public let certification: String?
    public let network: String?
    public let country: String?
    public let trailer: URL?
    public let homepage: URL?
    public let status: String?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: Date?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let airedEpisodes: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case year
        case ids
        
        case overview
        case firstAired = "first_aired"
        case airs
        case runtime
        case certification
        case network
        case country
        case trailer
        case homepage
        case status
        case rating
        case votes
        case updatedAt = "updated_at"
        case language
        case availableTranslations = "available_translations"
        case genres
        case airedEpisodes = "aired_episodes"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: CodingKeys.title)
        year = try container.decodeIfPresent(Int.self, forKey: CodingKeys.year)
        ids = try container.decode(ID.self, forKey: CodingKeys.ids)
        
        overview = try container.decodeIfPresent(String.self, forKey: CodingKeys.overview)
        firstAired = try container.decodeIfPresent(Date.self, forKey: CodingKeys.firstAired)
        airs = try container.decodeIfPresent(Airs.self, forKey: CodingKeys.airs)
        runtime = try container.decodeIfPresent(Int.self, forKey: CodingKeys.runtime)
        certification = try container.decodeIfPresent(String.self, forKey: .certification)
        network = try container.decodeIfPresent(String.self, forKey: .network)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        trailer = try? container.decode(URL.self, forKey: .trailer)
        homepage = try? container.decode(URL.self, forKey: .homepage)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        votes = try container.decodeIfPresent(Int.self, forKey: .votes)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        availableTranslations = try container.decodeIfPresent([String].self, forKey: .availableTranslations)
        genres = try container.decodeIfPresent([String].self, forKey: .genres)
        airedEpisodes = try container.decodeIfPresent(Int.self, forKey: .airedEpisodes)
    }
}
