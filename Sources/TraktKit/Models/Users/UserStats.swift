//
//  UserStats.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct UserStats: TraktObject {
    public let movies: Movies
    public let shows: Shows
    public let seasons: Seasons
    public let episodes: Episodes
    public let network: Network
    public let ratings: UserStatsRatingsDistribution
    
    public struct Movies: TraktObject {
        public let plays: Int
        public let watched: Int
        public let minutes: Int
        public let collected: Int
        public let ratings: Int
        public let comments: Int
    }
    
    public struct Shows: TraktObject {
        public let watched: Int
        public let collected: Int
        public let ratings: Int
        public let comments: Int
    }
    
    public struct Seasons: TraktObject {
        public let ratings: Int
        public let comments: Int
    }
    
    public struct Episodes: TraktObject {
        public let plays: Int
        public let watched: Int
        public let minutes: Int
        public let collected: Int
        public let ratings: Int
        public let comments: Int
    }
    
    public struct Network: TraktObject {
        public let friends: Int
        public let followers: Int
        public let following: Int
    }
    
    public struct UserStatsRatingsDistribution: TraktObject {
        public let total: Int
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
}
