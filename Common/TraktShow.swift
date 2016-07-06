//
//  TraktShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktShow: TraktProtocol {
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let overview: String?
    public let firstAired: NSDate?
    public let airs: RawJSON? // TODO: Make as type
    public let runtime: Int?
    public let certification: String?
    public let network: String?
    public let country: String?
    public let trailer: URL?
    public let homepage: URL?
    public let status: String?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: NSDate?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let airedEpisodes: Int?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        // Extended: Min
        self.title          = json["title"] as? String ?? ""
        self.year           = json["year"] as? Int
        self.ids            = ids
        
        // Extended: Full
        self.overview       = json["overview"] as? String
        self.firstAired     = NSDate.dateFromString(json["first_aired"])
        self.airs           = json["airs"] as? RawJSON
        self.runtime        = json["runtime"] as? Int
        self.certification  = json["certification"] as? String
        self.network        = json["network"] as? String
        self.country        = json["country"] as? String
        self.trailer        = (json["trailer"] as? String)?.toURL()
        self.homepage       = (json["homepage"] as? String)?.toURL()
        self.status         = json["status"] as? String
        self.rating         = json["rating"] as? Double
        self.votes          = json["votes"] as? Int
        self.updatedAt      = NSDate.dateFromString(json["updated_at"])
        self.language       = json["language"] as? String
        self.availableTranslations = json["available_translations"] as? [String]
        self.genres         = json["genres"] as? [String]
        self.airedEpisodes  = json["aired_episodes"] as? Int
        
        // Extended: Images
        images = TraktImages(json: json["images"] as? RawJSON)
    }
}
