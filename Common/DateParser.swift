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

internal extension Date {
    
    // MARK: - Class
    
    static func dateFromString(_ string: Any?) -> Date? {
        guard
            let dateString = string as? String else { return nil }
        
        let count = dateString.characters.count
        if count <= 10 {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd"
        } else if count == 23 {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        } else {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        }
        
        return ISO8601DateFormatter.date(from: dateString)
    }
    
    func UTCDateString() -> String {
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let UTCString = self.dateString(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        dateFormatter.timeZone = TimeZone.current
        return UTCString
    }
    
    func dateString(withFormat format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

// Private

private let ISO8601DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()
