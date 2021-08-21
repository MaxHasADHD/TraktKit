//
//  TraktManager+AsyncAwait.swift
//  TraktKit
//
//  Created by Maxamilian Litteral on 6/14/21.
//  Copyright © 2021 Maximilian Litteral. All rights reserved.
//

import Foundation

@available(macOS 12.0, iOS 15.0, *)
extension TraktManager {
    func `get`<T: Codable>(_ path: String, resultType: T.Type = T.self) async throws -> Route<T> {
        Route(path: path, method: .GET, traktManager: self)
    }
}
