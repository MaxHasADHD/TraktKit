//
//  TraktManagerTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/8/25.
//

import Foundation
import Testing
import SwiftAPIClient
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct TraktManagerTests {
        @Test
        func pollForAccessTokenInvalidDeviceCode() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/oauth/device/token", result: .success(.init()), httpCode: 404)

            let deviceCodeJSON: [String: Any] = [
                "device_code": "d9c126a7706328d808914cfd1e40274b6e009f684b1aca271b9b3f90b3630d64",
                "user_code": "5055CC52",
                "verification_url": "https://trakt.tv/activate",
                "expires_in": 600,
                "interval": 5
            ]
            let deviceCode = try JSONDecoder().decode(DeviceCode.self, from: try JSONSerialization.data(withJSONObject: deviceCodeJSON))

            await #expect(throws: TraktManager.TraktTokenError.invalidDeviceCode, performing: {
                try await traktManager.pollForAccessToken(deviceCode: deviceCode)
            })
        }

        @Test
        func retryRequestSuccess() async throws {
            let traktManager = await authenticatedTraktManager()
            let urlString = "https://api.trakt.tv/retry_test"
            let url = try #require(URL(string: urlString))
            try mock(.GET, urlString, result: .success(Data()), httpCode: 429, headers: [.retry(5)])

            // Update mock in 2 seconds
            Task {
                try await Task.sleep(for: .seconds(2))
                try mock(.GET, urlString, result: .success(Data()), httpCode: 201, replace: true)
            }

            let request = URLRequest(url: url)
            let (_, response) = try await traktManager.fetchData(request: request, retryLimit: 2)
            let httpHeader = try #require(response as? HTTPURLResponse)
            #expect(httpHeader.statusCode == 201)
        }

        @Test func retryRequestFailed() async throws {
            let traktManager = await authenticatedTraktManager()
            let urlString = "https://api.trakt.tv/retry_test_failed"
            let url = try #require(URL(string: urlString))
            try mock(.GET, urlString, result: .success(Data()), httpCode: 429, headers: [.retry(3)])

            // Update mock in 2 seconds
            Task {
                try await Task.sleep(for: .seconds(1))
                try mock(.GET, urlString, result: .success(Data()), httpCode: 405, replace: true)
            }

            let request = URLRequest(url: url)

            await #expect(throws: SwiftAPIClient.APIError.noMethodFound, performing: {
                try await traktManager.fetchData(request: request, retryLimit: 2)
            })
        }

        @Test func fetchPaginatedResults() async throws {
            let traktManager = await authenticatedTraktManager()

            let path = "shows/paginated-results/trending"
            for p in 1...2 {
                let urlString = "https://api.trakt.tv/\(path)?page=\(p)&limit=10"
                let json: [[String: Any]] = (0..<10).map { i in
                    [
                        "watchers": Int.random(in: 0...100),
                        "show": [
                            "title": "Random show \(i)",
                            "year": 2025,
                            "ids": [
                                "trakt": Int.random(in: 0...1000),
                                "slug": "Random_show_\(i)"
                            ]
                        ]
                    ]
                }
                let data = try JSONSerialization.data(withJSONObject: json)
                try mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)], replace: true)
            }

            // Note: Creating a mock route to test pagination logic due to running into conflicts with other tests setting up mock data for the same endpoint.
            let mockTrendingRoute: Route<PagedObject<[TraktTrendingShow]>> = Route(path: path, method: .GET, traktManager: traktManager)

            let trending = try await mockTrendingRoute.limit(10).fetchAllPages()
            #expect(trending.count == 20)
        }

        @Test func streamPaginatedResults() async throws {
            let traktManager = await authenticatedTraktManager()

            var watchersByPage = [[Int]]()
            let path = "shows/paged-results/trending"
            for p in 1...2 {
                let urlString = "https://api.trakt.tv/\(path)?page=\(p)&limit=10"
                let json: [[String: Any]] = (0..<10).map { i in
                    [
                        "watchers": Int.random(in: 0...100),
                        "show": [
                            "title": "Random show \(i)",
                            "year": 2025,
                            "ids": [
                                "trakt": Int.random(in: 0...1000),
                                "slug": "Random_show_\(i)"
                            ]
                        ]
                    ]
                }
                watchersByPage.append(json.map { $0["watchers"] as? Int ?? 0 })
                let data = try JSONSerialization.data(withJSONObject: json)
                try mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)], replace: true)
            }

            // Note: Creating a mock route to test pagination logic due to running into conflicts with other tests setting up mock data for the same endpoint.
            let mockTrendingRoute: Route<PagedObject<[TraktTrendingShow]>> = Route(path: path, method: .GET, traktManager: traktManager)

            for try await page in mockTrendingRoute.limit(10).pagedResults() {
                let watchersForPage = watchersByPage.removeFirst()
                #expect(page.map { $0.watchers } == watchersForPage)
                #expect(page.count == 10)
            }
        }
    }
}
