//
//  TraktMovieTranslation.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktMovieTranslation: Codable {
    public let title: String
    public let overview: String
    public let tagline: String
    public let language: String
}
