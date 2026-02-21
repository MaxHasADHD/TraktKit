//
//  TraktBoxOfficeMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 5/1/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktBoxOfficeMovie: TraktObject {
    // Extended: Min
    public let revenue: Int
    public let movie: TraktMovie
}
