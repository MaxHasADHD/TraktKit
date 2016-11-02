//
//  TraktEpisode.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public class TraktEpisode: NSObject, TraktProtocol, NSCoding {
    
    // Extended: Min
    public let season: Int
    public let number: Int
    public let title: String? // Might be missing, TBA episode
    public let ids: EpisodeId
    
    // Extended: Full
    public let overview: String?
    public let rating: Double?
    public let votes: Int?
    public let firstAired: Date?
    public let updatedAt: Date?
    public let availableTranslations: [RawJSON]?
    
    // Initialize
    public required init?(json: RawJSON?) {
        guard
            let json = json,
            let season = json["season"] as? Int,
            let number = json["number"] as? Int,
            let ids = EpisodeId(json: json["ids"] as? RawJSON) else { return nil }
        
        // Min
        self.season = season
        self.number = number
        self.title  = json["title"] as? String
        self.ids    = ids
        
        // Full
        self.overview   = json["overview"] as? String
        self.rating     = json["rating"] as? Double
        self.votes      = json["votes"] as? Int
        self.firstAired = Date.dateFromString(json["first_aired"])
        self.updatedAt  = Date.dateFromString(json["updated_at"])
        self.availableTranslations = []
    }
    
    // MARK: NSCoding
    
    required public init?(coder aDecoder: NSCoder) {
        // Extended: Min
        self.season = aDecoder.decodeInteger(forKey: "season")
        self.number = aDecoder.decodeInteger(forKey: "number")
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.ids = aDecoder.decodeObject(forKey: "ids") as! EpisodeId
        
        // Extended: Full
        self.overview = aDecoder.decodeObject(forKey: "overview") as? String
        self.rating = aDecoder.decodeObject(forKey: "rating") as? Double
        self.votes = aDecoder.decodeObject(forKey: "votes") as? Int
        self.firstAired = aDecoder.decodeObject(forKey: "firstAired") as? Date
        self.updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? Date
        self.availableTranslations = []
    }
    
    public func encode(with aCoder: NSCoder) {
        // Extended: Min
        aCoder.encode(self.season, forKey: "season")
        aCoder.encode(self.number, forKey: "number")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.ids, forKey: "ids")
        
        // Extended: Full
        aCoder.encode(self.overview, forKey: "overview")
        aCoder.encode(self.rating, forKey: "rating")
        aCoder.encode(self.votes, forKey: "votes")
        aCoder.encode(self.firstAired, forKey: "firstAired")
        aCoder.encode(self.updatedAt, forKey: "updatedAt")
        aCoder.encode(self.availableTranslations, forKey: "availableTranslations")
    }
}
