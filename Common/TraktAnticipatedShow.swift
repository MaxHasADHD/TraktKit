//
//  TraktAnticipatedShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktAnticipatedShow: TraktProtocol {
    // Extended: Min
    public let listCount: Int
    public let show: TraktShow
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let listCount = json["list_count"] as? Int,
            let show = TraktShow(json: json["show"] as? RawJSON) else { return nil }
        
        self.listCount = listCount
        self.show = show
    }
}
