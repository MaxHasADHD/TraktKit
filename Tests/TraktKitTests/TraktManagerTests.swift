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
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }
        
        @Test
        func pollForAccessTokenInvalidDeviceCode() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/oauth/device/token", result: .success(.init()), httpCode: 404)

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
            let urlString = "https://api.trakt.tv/retry_test"
            let url = try #require(URL(string: urlString))
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: 429, headers: [.retry(5)])
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: 201)

            let request = URLRequest(url: url)
            let (_, response) = try await traktManager.fetchData(request: request, retryLimit: 2)
            let httpHeader = try #require(response as? HTTPURLResponse)
            #expect(httpHeader.statusCode == 201)
        }

        @Test func retryRequestFailed() async throws {
            let urlString = "https://api.trakt.tv/retry_test_failed"
            let url = try #require(URL(string: urlString))
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: 429, headers: [.retry(3)])
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: 405)

            let request = URLRequest(url: url)

            await #expect(throws: SwiftAPIClient.APIError.methodNotAllowed, performing: {
                try await traktManager.fetchData(request: request, retryLimit: 2)
            })
        }

        @Test func fetchPaginatedResults() async throws {
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
                try await suite.mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)], replace: true)
            }

            // Note: Creating a mock route to test pagination logic due to running into conflicts with other tests setting up mock data for the same endpoint.
            let mockTrendingRoute: Route<PagedObject<[TraktTrendingShow]>> = Route(path: path, method: .GET, traktManager: traktManager)

            let trending = try await mockTrendingRoute.limit(10).fetchAllPages()
            #expect(trending.count == 20)
        }

        @Test func streamPaginatedResults() async throws {
            

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
                try await suite.mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)], replace: true)
            }

            // Note: Creating a mock route to test pagination logic due to running into conflicts with other tests setting up mock data for the same endpoint.
            let mockTrendingRoute: Route<PagedObject<[TraktTrendingShow]>> = Route(path: path, method: .GET, traktManager: traktManager)

            for try await page in mockTrendingRoute.limit(10).pagedResults() {
                let watchersForPage = watchersByPage.removeFirst()
                #expect(page.map { $0.watchers } == watchersForPage)
                #expect(page.count == 10)
            }
        }

        // MARK: - Trakt-Specific Error Integration Tests

        @Test("Mock request with 420 status throws TraktAPIError.accountLimitExceeded")
        func accountLimitExceeded() async throws {
            
            let urlString = "https://api.trakt.tv/users/me/lists"
            try await suite.mock(.POST, urlString, result: .success(Data()), httpCode: StatusCodes.AccountLimitExceeded)

            let route: Route<TraktList> = Route(path: "users/me/lists", method: .POST, traktManager: traktManager)

            await #expect(throws: TraktAPIError.accountLimitExceeded) {
                try await route.perform()
            }
        }

        @Test("Mock request with 423 status throws TraktAPIError.accountLocked")
        func accountLocked() async throws {
            
            let urlString = "https://api.trakt.tv/sync/collection"
            try await suite.mock(.POST, urlString, result: .success(Data()), httpCode: StatusCodes.acountLocked)

            let route: EmptyRoute = EmptyRoute(path: "sync/collection", method: .POST, traktManager: traktManager)

            await #expect(throws: TraktAPIError.accountLocked) {
                try await route.perform()
            }
        }

        @Test("Mock request with 426 status throws TraktAPIError.vipOnly")
        func vipOnly() async throws {
            
            let urlString = "https://api.trakt.tv/users/saved_filters"
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: StatusCodes.vipOnly)

            let route: Route<[SavedFilter]> = Route(path: "users/saved_filters", method: .GET, traktManager: traktManager)

            await #expect(throws: TraktAPIError.vipOnly) {
                try await route.perform()
            }
        }

        @Test("Mock request with 520 status throws TraktAPIError.cloudflareError")
        func cloudflareError520() async throws {
            
            let urlString = "https://api.trakt.tv/movies/trending"
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: StatusCodes.CloudflareError)

            let route: Route<[TraktTrendingMovie]> = Route(path: "movies/trending", method: .GET, traktManager: traktManager)

            await #expect(throws: TraktAPIError.cloudflareError(statusCode: 520)) {
                try await route.perform()
            }
        }

        @Test("Mock request with 521 status throws TraktAPIError.cloudflareError")
        func cloudflareError521() async throws {
            
            let urlString = "https://api.trakt.tv/shows/trending"
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: StatusCodes.CloudflareError2)

            let route: Route<[TraktTrendingShow]> = Route(path: "shows/trending", method: .GET, traktManager: traktManager)

            await #expect(throws: TraktAPIError.cloudflareError(statusCode: 521)) {
                try await route.perform()
            }
        }

        @Test("Mock request with 522 status throws TraktAPIError.cloudflareError")
        func cloudflareError522() async throws {
            
            let urlString = "https://api.trakt.tv/search"
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: StatusCodes.CloudflareError3)

            let route: Route<[TraktMovie]> = Route(path: "search", method: .GET, traktManager: traktManager)

            await #expect(throws: TraktAPIError.cloudflareError(statusCode: 522)) {
                try await route.perform()
            }
        }

        @Test("Mock request with standard 404 still throws TraktError.notFound")
        func standardErrorStillWorks() async throws {
            
            let urlString = "https://api.trakt.tv/movies/invalid-id"
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: 404)

            let route: Route<TraktMovie> = Route(path: "movies/invalid-id", method: .GET, traktManager: traktManager)

            await #expect(throws: TraktError.notFound) {
                try await route.perform()
            }
        }
    }
}
