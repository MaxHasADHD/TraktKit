//
//  Extensions.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/30/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension String: CustomStringConvertible {
    public var description: String {
        return self
    }
}

extension NSURL {
    @nonobjc convenience init?(string: AnyObject?) {
        guard let dateString = string as? String else { return nil }
        self.init(string: dateString)
    }
}
