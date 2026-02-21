//
//  TraktDVDReleaseMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/26/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktDVDReleaseMovie: TraktObject {
    // Extended: Min
    public let released: Date
    public let movie: TraktMovie
}
