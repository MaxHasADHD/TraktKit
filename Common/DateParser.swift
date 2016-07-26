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
    
    static func dateFromString(_ string: AnyObject?) -> Date? {
        guard
            let dateString = string as? String else { return nil }
        
        let count = dateString.characters.count
        if count <= 10 {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd"
        }
        else {
            ISO8601DateFormatter.dateFormat = UTCFormat
        }
        
        return ISO8601DateFormatter.date(from: dateString)
    }
}

// Private

private let UTCFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

private let ISO8601DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()
