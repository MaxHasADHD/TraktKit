//
//  TraktAnticipatedShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktAnticipatedShow: TraktObject {
    
    // Extended: Min
    public let listCount: Int
    public let show: TraktShow
    
    enum CodingKeys: String, CodingKey {
        case listCount = "list_count"
        case show
    }
}
