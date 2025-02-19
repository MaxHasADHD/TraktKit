//
//  Filters.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/26/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public protocol FilterType: Sendable {
    func value() -> (key: String, value: String)
}

public extension TraktManager {
    /**
     Some `movies`, `shows`, `calendars`, and `search` methods support additional filters and will be tagged with 🎚 Filters. Applying these filters refines the results and helps your users to more easily discover new items.
     
     Add a query string (i.e. `?years=2016&genres=action`) with any filters you want to use. Some filters allow multiples which can be sent as comma delimited parameters. For example, `?genres=action,adventure` would match the `action` OR `adventure` genre.
     
     **Note**: Make sure to properly URL encode the parameters including spaces and special characters.
     */
    enum Filter: FilterType {
        /**
         4 digit year.
         */
        case year(year: NSNumber)
        /**
         Genre slugs.
         */
        case genres(genres: [String])
        /**
         2 character language code.
         */
        case languages(languages: [String])
        /** 2 character country code.
         */
        case countries(countries: [String])
        /**
         Range in minutes.
         */
        case runtimes(runtimes: (lower: NSNumber, upper: NSNumber))
        /**
         Range between `0` and `100`.
         */
        case ratings(ratings: (lower: NSNumber, upper: NSNumber))
        
        // FilterType
        public func value() -> (key: String, value: String) {
            switch self {
            case .year(let year):
                return ("years", "\(year)")
            case .genres(let genres):
                return ("genres", genres.joined(separator: ","))
            case .languages(let languages):
                return ("languages", languages.joined(separator: ","))
            case .countries(let countries):
                return ("countries", countries.joined(separator: ","))
            case .runtimes(runtimes: (let lower, let upper)):
                return ("runtimes", "\(lower)-\(upper)")
            case .ratings(ratings: (let lower, let upper)):
                return ("ratings", "\(lower)-\(upper)")
            }
        }
    }
    
    enum MovieFilter: FilterType {
        /**
         US content certification.
         */
        case certifications(certifications: [String])
        
        // FilterType
        public func value() -> (key: String, value: String) {
            switch self {
            case .certifications(let certifications):
                return ("genres", certifications.joined(separator: ","))
            }
        }
    }
    
    enum ShowFilter: FilterType {
        /**
         US content certification.
         */
        case certifications(certifications: [String])
        /**
         Network name.
         */
        case networks(networks: [String])
        /**
         Set to `returning series`, `in production`, `planned`, `canceled`, or `ended`.
         */
        case status(status: [String])
        
        // FilterType
        public func value() -> (key: String, value: String) {
            switch self {
            case .certifications(let certifications):
                return ("genres", certifications.joined(separator: ","))
            case .networks(let networks):
                return ("networks", networks.joined(separator: ","))
            case .status(let status):
                return ("status", status.joined(separator: ","))
            }
        }
    }
}
