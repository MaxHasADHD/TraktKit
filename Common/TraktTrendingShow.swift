//
//  TraktTrendingShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktTrendingShow: TraktProtocol {
    // Extended: Min
    public let watchers: Int
    public let show: TraktShow
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let watchers = json["watchers"] as? Int,
            let show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.watchers = watchers
        self.show = show
    }
}
