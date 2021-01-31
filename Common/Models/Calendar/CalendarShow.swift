//
//  CalendarShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/14/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CalendarShow: Codable, Hashable {
    public let firstAired: Date
    public let episode: TraktEpisode
    public let show: TraktShow
    
    enum CodingKeys: String, CodingKey {
        case firstAired = "first_aired"
        case episode
        case show
    }
}
