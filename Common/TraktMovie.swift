//
//  TraktMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktMovie: TraktProtocol {
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let tagline: String?
    public let overview: String?
    public let released: NSDate?
    public let runtime: Int?
    public let trailer: NSURL?
    public let homepage: NSURL?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: NSDate?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let certification: String?
    
    // Extended: Images
    public let images: TraktImages?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            title = json["title"] as? String,
            ids = ID(json: json["ids"] as? RawJSON) else { return nil }
        
        // Extended: Min
        self.title              = title
        self.year               = json["year"] as? Int
        self.ids                = ids
        
        // Extended: Full
        self.tagline            = json["overview"] as? String
        self.overview           = json["overview"] as? String
        self.released           = NSDate.dateFromString(json["released"] as? String)
        self.runtime            = json["runtime"] as? Int
        self.trailer            = (json["trailer"] as? String)?.URL()
        self.homepage           = (json["homepage"] as? String)?.URL()
        self.rating             = json["rating"] as? Double
        self.votes              = json["votes"] as? Int
        self.updatedAt          = NSDate.dateFromString(json["updated_at"] as? String)
        self.language           = json["language"] as? String
        self.availableTranslations = json["available_translations"] as? [String]
        self.genres             = json["genres"] as? [String]
        self.certification      = json["certification"] as? String
        
        // Extended: Images
        if let imageJSON = json["images"] as? RawJSON {
            images = TraktImages(json: imageJSON)
        }
        else {
            images = nil
        }
    }
}
