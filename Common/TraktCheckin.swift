//
//  TraktCheckin.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/29/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public class TraktCheckin: NSObject, TraktProtocol, NSCoding {
    
    /// Trakt History ID
    public let id: Int
    public let watchedAt: Date
    public let sharing: RawJSON
    
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let episode: TraktEpisode?
    
    // Initialize
    
    public required init?(json: RawJSON?) {
        guard
            let json = json,
            let id = json["id"] as? Int,
            let watchedAt = Date.dateFromString(json["watched_at"]),
            let sharing = json["sharing"] as? [String: AnyObject] else { return nil }
        
        self.id = id
        self.watchedAt = watchedAt
        self.sharing = sharing
        
        self.movie = TraktMovie(json: json["movie"] as? RawJSON)
        self.show = TraktShow(json: json["show"] as? RawJSON)
        self.episode = TraktEpisode(json: json["episode"] as? RawJSON)
    }
    
    // MARK: NSCoding
    
    required public init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.watchedAt = aDecoder.decodeObject(forKey: "watched_at") as? Date ?? Date()
        self.sharing = aDecoder.decodeObject(forKey: "sharing") as? RawJSON ?? [:]
        
        self.movie = aDecoder.decodeObject(forKey: "movie") as? TraktMovie
        self.show = aDecoder.decodeObject(forKey: "show") as? TraktShow
        self.episode = aDecoder.decodeObject(forKey: "episode") as? TraktEpisode
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.watchedAt, forKey: "watched_at")
        aCoder.encode(self.sharing, forKey: "sharing")
        
        aCoder.encode(self.movie, forKey: "movie")
        aCoder.encode(self.show, forKey: "show")
        aCoder.encode(self.episode, forKey: "episode")
    }
}
