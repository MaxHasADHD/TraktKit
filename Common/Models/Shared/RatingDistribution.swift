//
//  RatingDistribution.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct RatingDistribution: TraktObject {
    public let rating: Double
    public let votes: Int
    public let distribution: Distribution
    
    public struct Distribution: TraktObject {
        public let one: Int
        public let two: Int
        public let three: Int
        public let four: Int
        public let five: Int
        public let six: Int
        public let seven: Int
        public let eight: Int
        public let nine: Int
        public let ten: Int
        
        enum CodingKeys: String, CodingKey {
            case one    = "1"
            case two    = "2"
            case three  = "3"
            case four   = "4"
            case five   = "5"
            case six    = "6"
            case seven  = "7"
            case eight  = "8"
            case nine   = "9"
            case ten    = "10"
        }
    }
}
