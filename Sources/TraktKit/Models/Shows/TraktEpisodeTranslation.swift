//
//  TraktEpisodeTranslation.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/28/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktEpisodeTranslation: TraktObject {
    public let title: String
    public let overview: String
    public let language: String
}

public struct TraktSeasonTranslation: TraktObject {
    public let title: String
    public let overview: String
    public let language: String
    public let country: String
}
