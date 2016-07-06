//
//  DateParser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/25/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

// Internal
internal let calendar = NSCalendar.currentCalendar()
internal let dateFormatter = NSDateFormatter()

internal extension NSDate {
    
    // MARK: - Class
    
    class func dateFromString(string: AnyObject?) -> NSDate? {
        guard let dateString = string as? String else { return nil }
        
        let count = dateString.characters.count
        if count <= 10 {
            ISO8601DateFormatter.dateFormat = "yyyy-MM-dd"
        }
        else {
            ISO8601DateFormatter.dateFormat = UTCFormat
        }
        
        return ISO8601DateFormatter.dateFromString(dateString)
    }
}

// Private

private let UTCFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

private let ISO8601DateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()
