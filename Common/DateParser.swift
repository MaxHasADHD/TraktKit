//
//  DateParser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 1/25/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

internal let calendar = NSCalendar.currentCalendar()
internal let dateFormatter = NSDateFormatter()

internal let ISO8601DateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

internal extension NSDate {
    
    // MARK: - Class
    
    class func dateFromString(string: String?) -> NSDate? {
        guard let dateString = string else { return nil }
        return ISO8601DateFormatter.dateFromString(dateString)
    }
}