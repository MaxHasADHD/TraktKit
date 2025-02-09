//
//  DateParser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/25/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

// Internal
internal let calendar = Calendar.current
internal let dateFormatter = DateFormatter()

@Sendable
public func customDateDecodingStrategy(decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let str = try container.decode(String.self)
    return try Date.dateFromString(str)
}

internal extension Date {
    
    enum DateParserError: Error {
        case failedToParseDateFromString(String)
    }
    
    // MARK: - Class
    
    static func dateFromString(_ dateString: String) throws(DateParserError) -> Date {
        let count = dateString.count
        if count <= 10 {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd"
        } else if count == 23 {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        } else {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        }

        if let date = ISO8601DateFormatter.date(from: dateString) {
            return date
        } else {
            throw .failedToParseDateFromString("String to parse: \(dateString), date format: \(String(describing: ISO8601DateFormatter.dateFormat))")
        }
    }
    
    func UTCDateString() -> String {
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let UTCString = self.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        dateFormatter.timeZone = TimeZone.current
        return UTCString
    }
    
    func dateString(withFormat format: String) -> String {
        ISO8601DateFormatter.dateFormat = format
        return ISO8601DateFormatter.string(from: self)
    }
}

// Private

private let ISO8601DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT") ?? TimeZone.current
    return dateFormatter
}()
