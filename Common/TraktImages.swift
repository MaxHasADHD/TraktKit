//
//  TraktImages.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktImages: TraktProtocol {
    public let fanart: TraktImage?
    public let poster: TraktImage?
    public let logo: TraktImage?
    public let clearArt: TraktImage?
    public let banner: TraktImage?
    public let thumb: TraktImage?
    public let headshot: TraktImage?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json else { return nil }
        
        fanart      = TraktImage(json: json["fanart"] as? RawJSON)
        poster      = TraktImage(json: json["poster"] as? RawJSON)
        logo        = TraktImage(json: json["logo"] as? RawJSON)
        clearArt    = TraktImage(json: json["clearart"] as? RawJSON)
        banner      = TraktImage(json: json["banner"] as? RawJSON)
        thumb       = TraktImage(json: json["thumb"] as? RawJSON)
        headshot    = TraktImage(json: json["headshot"] as? RawJSON) // For actors
    }
}

public struct TraktImage: TraktProtocol {
    public let full: NSURL?
    public let medium: NSURL?
    public let thumb: NSURL?
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json else { return nil }
        full    = NSURL(string: json["full"] as? String ?? "")
        medium  = NSURL(string: json["medium"] as? String ?? "")
        thumb   = NSURL(string: json["thumb"] as? String ?? "")
    }
}
