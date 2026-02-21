//
//  UsersComments.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct UsersComments: TraktObject {
    public let type: String
    public let comment: Comment
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let season: TraktSeason?
    public let episode: TraktEpisode?
}
