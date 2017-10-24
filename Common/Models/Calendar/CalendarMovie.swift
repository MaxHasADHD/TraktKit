//
//  CalendarMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/14/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CalendarMovie: Codable {
    public let released: Date
    public let movie: TraktMovie
}
