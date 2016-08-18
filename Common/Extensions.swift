//
//  Extensions.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/30/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension String {
    public var description: String {
        return self
    }
}

extension String {
    func toURL() -> URL? {
        guard self.isEmpty == false else { return nil }
        
        return URL(string: self)
    }
}
