//
//  CalendarMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/14/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CalendarMovie: Codable {
    let released: Date
    let movie: TraktMovie
}
