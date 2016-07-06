//
//  DateParser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/25/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

internal let calendar = Calendar.current
internal let dateFormatter = DateFormatter()

internal let ISO8601DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

internal extension NSDate {
    
    // MARK: - Class
    
    class func dateFromString(_ string: AnyObject?) -> NSDate? {
        guard let dateString = string as? String else { return nil }
        return ISO8601DateFormatter.date(from: dateString)
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
