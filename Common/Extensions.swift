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

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }

    func asArray() throws -> [[String: Any]] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
            throw NSError()
        }
        return dictionary
    }
}
