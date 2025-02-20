//
//  TraktTrendingShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktTrendingShow: TraktObject {
    public let watchers: Int
    public let show: TraktShow
}

public struct TraktFavoritedShow: TraktObject {
    public let userCount: Int
    public let show: TraktShow

    enum CodingKeys: String, CodingKey {
        case userCount = "user_count"
        case show
    }
}
