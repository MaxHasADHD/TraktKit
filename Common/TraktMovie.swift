//
//  TraktMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public class TraktMovie: NSObject, TraktProtocol, NSCoding {
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
    
    // Initialize
    public required init?(json: RawJSON?) {
        guard
            let json = json,
            let title = json["title"] as? String,
            let ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        // Extended: Min
        self.title              = title
        self.year               = json["year"] as? Int
        self.ids                = ids
        
        // Extended: Full
        self.tagline            = json["overview"] as? String
        self.overview           = json["overview"] as? String
        self.released = Date.dateFromString(json["released"])
        self.runtime            = json["runtime"] as? Int
        self.trailer            = (json["trailer"] as? String)?.toURL()
        self.homepage           = (json["homepage"] as? String)?.toURL()
        self.rating             = json["rating"] as? Double
        self.votes              = json["votes"] as? Int
        self.updatedAt = Date.dateFromString(json["updated_at"])
        self.language           = json["language"] as? String
        self.availableTranslations = json["available_translations"] as? [String]
        self.genres             = json["genres"] as? [String]
        self.certification      = json["certification"] as? String
    }
    
    // MARK: NSCoding
    
    required public init?(coder aDecoder: NSCoder) {
        // Extended: Min
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.year = aDecoder.decodeObject(forKey: "year") as? Int
        self.ids = aDecoder.decodeObject(forKey: "ids") as! ID
        
        // Extended: Full
        self.tagline = aDecoder.decodeObject(forKey: "tagline") as? String
        self.overview = aDecoder.decodeObject(forKey: "overview") as? String
        self.released = aDecoder.decodeObject(forKey: "released") as? Date
        self.runtime = aDecoder.decodeObject(forKey: "runtime") as? Int
        self.trailer = (aDecoder.decodeObject(forKey: "trailer") as? String)?.toURL()
        self.homepage = (aDecoder.decodeObject(forKey: "homepage") as? String)?.toURL()
        self.rating = aDecoder.decodeObject(forKey: "rating") as? Double
        self.votes = aDecoder.decodeObject(forKey: "votes") as? Int
        self.updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? Date
        self.language = aDecoder.decodeObject(forKey: "language") as? String
        self.availableTranslations = aDecoder.decodeObject(forKey: "availableTranslations") as? [String]
        self.genres = aDecoder.decodeObject(forKey: "genres") as? [String]
        self.certification = aDecoder.decodeObject(forKey: "certification") as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        // Extended: Min
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.year, forKey: "year")
        aCoder.encode(self.ids, forKey: "ids")
        
        // Extended: Full
        aCoder.encode(self.tagline, forKey: "tagline")
        aCoder.encode(self.overview, forKey: "overview")
        aCoder.encode(self.released, forKey: "released")
        aCoder.encode(self.runtime, forKey: "runtime")
        aCoder.encode(self.trailer, forKey: "trailer")
        aCoder.encode(self.homepage, forKey: "homepage")
        aCoder.encode(self.rating, forKey: "rating")
        aCoder.encode(self.votes, forKey: "votes")
        aCoder.encode(self.updatedAt, forKey: "updatedAt")
        aCoder.encode(self.language, forKey: "language")
        aCoder.encode(self.availableTranslations, forKey: "availableTranslations")
        aCoder.encode(self.genres, forKey: "genres")
        aCoder.encode(self.certification, forKey: "certification")
    }
}
