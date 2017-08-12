//
//  UserStats.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/12/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct UserStats: Codable {
    let movies: Movies
    let shows: Shows
    let seasons: Seasons
    let episodes: Episodes
    let network: Network
    let ratings: UserStatsRatingsDistribution
    
    public struct Movies: Codable {
        let plays: Int
        let watched: Int
        let minutes: Int
        let collected: Int
        let ratings: Int
        let comments: Int
    }
    
    public struct Shows: Codable {
        let watched: Int
        let collected: Int
        let ratings: Int
        let comments: Int
    }
    
    public struct Seasons: Codable {
        let ratings: Int
        let comments: Int
    }
    
    public struct Episodes: Codable {
        let plays: Int
        let watched: Int
        let minutes: Int
        let collected: Int
        let ratings: Int
        let comments: Int
    }
    
    public struct Network: Codable {
        let friends: Int
        let followers: Int
        let following: Int
    }
    
    public struct UserStatsRatingsDistribution: Codable {
        let total: Int
        let distribution: Distribution
        
        public struct Distribution: Codable {
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
