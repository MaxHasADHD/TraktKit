//
//  TraktShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public class TraktShow: NSObject, TraktProtocol, NSCoding {
    
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let overview: String?
    public let firstAired: Date?
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
    public let updatedAt: Date?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let airedEpisodes: Int?
    
    // Initialize
    public required init?(json: RawJSON?) {
        guard
            let json = json,
            let ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        // Extended: Min
        self.title          = json["title"] as? String ?? ""
        self.year           = json["year"] as? Int
        self.ids            = ids
        
        // Extended: Full
        self.overview       = json["overview"] as? String
        self.firstAired     = Date.dateFromString(json["first_aired"])
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
        self.updatedAt      = Date.dateFromString(json["updated_at"])
        self.language       = json["language"] as? String
        self.availableTranslations = json["available_translations"] as? [String]
        self.genres         = json["genres"] as? [String]
        self.airedEpisodes  = json["aired_episodes"] as? Int
    }
    
    // MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        // Extended: Min
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.year = aDecoder.decodeInteger(forKey: "year")
        self.ids = aDecoder.decodeObject(forKey: "ids") as! ID
        
        // Extended: Full
        self.overview = aDecoder.decodeObject(forKey: "overview") as? String
        self.firstAired = aDecoder.decodeObject(forKey: "firstAired") as? Date
        self.airs = aDecoder.decodeObject(forKey: "airs") as? RawJSON
        self.runtime = aDecoder.decodeObject(forKey: "runtime") as? Int
        self.certification = aDecoder.decodeObject(forKey: "certification") as? String
        self.network = aDecoder.decodeObject(forKey: "network") as? String
        self.country = aDecoder.decodeObject(forKey: "country") as? String
        self.trailer = (aDecoder.decodeObject(forKey: "trailer") as? String)?.toURL()
        self.homepage = (aDecoder.decodeObject(forKey: "homepage") as? String)?.toURL()
        self.status = aDecoder.decodeObject(forKey: "status") as? String
        self.rating = aDecoder.decodeObject(forKey: "rating") as? Double
        self.votes = aDecoder.decodeObject(forKey: "votes") as? Int
        self.updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? Date
        self.language = aDecoder.decodeObject(forKey: "language") as? String
        self.availableTranslations = aDecoder.decodeObject(forKey: "availableTranslations") as? [String]
        self.genres = aDecoder.decodeObject(forKey: "genres") as? [String]
        self.airedEpisodes = aDecoder.decodeInteger(forKey: "airedEpisodes")
    }
    
    public func encode(with aCoder: NSCoder) {
        // Extended: Min
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.year, forKey: "year")
        aCoder.encode(self.ids, forKey: "ids")
        
        // Extended: Full
        aCoder.encode(self.overview, forKey: "overview")
        aCoder.encode(self.firstAired, forKey: "firstAired")
        aCoder.encode(self.airs, forKey: "airs")
        aCoder.encode(self.runtime, forKey: "runtime")
        aCoder.encode(self.certification, forKey: "certification")
        aCoder.encode(self.network, forKey: "network")
        aCoder.encode(self.country, forKey: "country")
        aCoder.encode(self.trailer, forKey: "trailer")
        aCoder.encode(self.homepage, forKey: "homepage")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.rating, forKey: "rating")
        aCoder.encode(self.votes, forKey: "votes")
        aCoder.encode(self.updatedAt, forKey: "updatedAt")
        aCoder.encode(self.language, forKey: "language")
        aCoder.encode(self.availableTranslations, forKey: "availableTranslations")
        aCoder.encode(self.genres, forKey: "genres")
        aCoder.encode(self.airedEpisodes, forKey: "airedEpisodes")
    }
}
