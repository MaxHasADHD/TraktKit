//
//  TraktManagerTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/8/25.
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct TraktManagerTests {
        @Test
        func pollForAccessTokenInvalidDeviceCode() async throws {
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
            let urlString = "https://api.trakt.tv/retry_test"
            try mock(.GET, urlString, result: .success(Data()), httpCode: 429, headers: [.retry(5)])

            // Update mock in 2 seconds
            Task.detached {
                try await Task.sleep(for: .seconds(2))
                try mock(.GET, urlString, result: .success(Data()), httpCode: 201, replace: true)
            }

            let request = URLRequest(url: URL(string: urlString)!)
            let (_, response) = try await traktManager.fetchData(request: request, retryLimit: 2)
            let httpHeader = try #require(response as? HTTPURLResponse)
            #expect(httpHeader.statusCode == 201)
        }

        @Test func retryRequestFailed() async throws {
            let urlString = "https://api.trakt.tv/retry_test_failed"
            try mock(.GET, urlString, result: .success(Data()), httpCode: 429, headers: [.retry(3)])

            // Update mock in 2 seconds
            Task.detached {
                try await Task.sleep(for: .seconds(1))
                try mock(.GET, urlString, result: .success(Data()), httpCode: 405, replace: true)
            }

            let request = URLRequest(url: URL(string: urlString)!)

            await #expect(throws: TraktManager.TraktError.noMethodFound, performing: {
                try await traktManager.fetchData(request: request, retryLimit: 2)
            })
        }

        @Test func fetchPaginatedResults() async throws {
            for p in 1...2 {
                let urlString = "https://api.trakt.tv/shows/trending?page=\(p)&limit=10"
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
                try mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)])
            }

            let trending = try await traktManager.shows.trending().limit(10).fetchAllPages()
            #expect(trending.count == 20)
        }

        @Test func streamPaginatedResults() async throws {
            var watchersByPage = [[Int]]()
            for p in 1...2 {
                let urlString = "https://api.trakt.tv/shows/trending?page=\(p)&limit=10"
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
                try mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)])
            }

            for try await page in traktManager.shows.trending().limit(10).pagedResults() {
                let watchersForPage = watchersByPage.removeFirst()
                #expect(page.map { $0.watchers } == watchersForPage)
                #expect(page.count == 10)
            }
        }
    }
}
