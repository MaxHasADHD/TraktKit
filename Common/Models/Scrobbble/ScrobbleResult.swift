//
//  ScrobbleResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct ScrobbleResult: Codable {
    let id: Int
    let action: String
    let progress: Float
    let movie: TraktMovie?
    let episode: TraktEpisode?
    let show: TraktShow?
}
