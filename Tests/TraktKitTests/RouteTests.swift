//
//  RouteTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/3/25.
//

import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct RouteTests {

        @Test
        func buildRequest() {
            let route = traktManager.shows.trending()
        }
    }
}
