//
//  TraktTrendingComments.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/24/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktTrendingComment: TraktObject {
    public let type: String
    public let comment: Comment
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let season: TraktSeason?
    public let episode: TraktEpisode?
}
