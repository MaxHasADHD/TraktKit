//
//  TraktSearchResult.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktSearchResult: TraktObject {
    public let type: String // Can be movie, show, episode, person, list
    public let score: Double?
    
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let episode: TraktEpisode?
    public let person: Person?
    public let list: TraktList?
}
