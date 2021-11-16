//
//  ScrobbleResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ScrobbleResult: Codable, Hashable {
    public let id: Int
    public let action: String
    public let progress: Float
    public let movie: TraktMovie?
    public let episode: TraktEpisode?
    public let show: TraktShow?
}
