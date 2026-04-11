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
    @Suite(.timeLimit(.minutes(5)))
    struct TraktManagerTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }
        
        @Test("Configuration includes required additional headers")
        func configurationIncludesRequiredHeaders() {
            let expectedHeaders = [
                "trakt-api-version": "2",
                "trakt-api-key": "",
                "User-Agent": "myapp/1.0.0"
            ]
            #expect(traktManager.configuration.additionalHeaders == expectedHeaders)
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
                try await suite.mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)])
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
                try await suite.mock(.GET, urlString, result: .success(data), headers: [.page(p), .pageCount(2)])
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
            try await suite.mock(.POST, urlString, result: .success(Data()), httpCode: StatusCodes.accountLocked)

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

        @Test("Mock request with standard 404 still throws TraktError.notFound", .timeLimit(.minutes(1)))
        func standardErrorStillWorks() async throws {
            
            let urlString = "https://api.trakt.tv/movies/invalid-id"
            try await suite.mock(.GET, urlString, result: .success(Data()), httpCode: 404)

            let route: Route<TraktMovie> = Route(path: "movies/invalid-id", method: .GET, traktManager: traktManager)

            await #expect(throws: TraktError.notFound) {
                try await route.perform()
            }
        }
        
        // MARK: - Automatic Token Refresh Tests
        
        @Test("Proactive token refresh - token expires within 1 hour", .timeLimit(.minutes(1)))
        func proactiveTokenRefreshSuccess() async throws {
            // Create manager with token that expires in 30 minutes
            let expirationDate = Date().addingTimeInterval(1800) // 30 minutes from now
            let mockAuth = TraktMockAuthStorage(
                accessToken: "old_access_token",
                refreshToken: "valid_refresh_token",
                expirationDate: expirationDate
            )
            
            let manager = await TraktManager(
                session: suite.mockSession.urlSession,
                clientId: "test_client",
                clientSecret: "test_secret",
                redirectURI: "test://redirect",
                userAgent: "myapp/1.0.0",
                authStorage: mockAuth
            )
            
            // Mock the refresh token endpoint
            let refreshTokenURL = "https://api.trakt.tv/oauth/token"
            let newTokenResponse: [String: Any] = [
                "access_token": "new_access_token",
                "token_type": "bearer",
                "expires_in": 86400, // 24 hours
                "refresh_token": "new_refresh_token",
                "scope": "public",
                "created_at": Int(Date().timeIntervalSince1970)
            ]
            let refreshData = try JSONSerialization.data(withJSONObject: newTokenResponse)
            try await suite.mock(.POST, refreshTokenURL, result: .success(refreshData), httpCode: 200, headers: [.contentType])
            
            // Mock the actual request (use authenticated endpoint)
            let watchlistURL = "https://api.trakt.tv/sync/watchlist/movies"
            let watchlistJSON: [[String: Any]] = [
                [
                    "rank": 1,
                    "id": 12345,
                    "listed_at": "2025-02-25T12:00:00.000Z",
                    "type": "movie",
                    "movie": [
                        "title": "Test Movie",
                        "year": 2025,
                        "ids": [
                            "trakt": 12345,
                            "slug": "test-movie"
                        ]
                    ]
                ]
            ]
            let watchlistData = try JSONSerialization.data(withJSONObject: watchlistJSON)
            try await suite.mock(.GET, watchlistURL, result: .success(watchlistData), headers: [.contentType, .apiVersion, .apiKey("test_client"), .page(1), .pageCount(1)])
            
            // Make authenticated request - should proactively refresh token before making the request
            let result = try await manager.sync().watchlist(type: "movies").perform()
            
            // Verify request succeeded
            #expect(result.object.count == 1)
            
            // Verify token was updated in storage
            let updatedState = try await mockAuth.getCurrentState()
            #expect(updatedState.accessToken == "new_access_token")
            #expect(updatedState.refreshToken == "new_refresh_token")
        }
        
        @Test("Reactive token refresh - 401 error triggers token refresh and retry", .timeLimit(.minutes(1)))
        func reactiveTokenRefreshOn401() async throws {
            // Create manager with valid token
            let expirationDate = Date().addingTimeInterval(7200) // 2 hours from now
            let mockAuth = TraktMockAuthStorage(
                accessToken: "expired_access_token",
                refreshToken: "valid_refresh_token",
                expirationDate: expirationDate
            )
            
            let manager = await TraktManager(
                session: suite.mockSession.urlSession,
                clientId: "test_client",
                clientSecret: "test_secret",
                redirectURI: "test://redirect",
                userAgent: "myapp/1.0.0",
                authStorage: mockAuth
            )
            
            // First request with old token returns 401
            let watchlistURL = "https://api.trakt.tv/users/me/watchlist"
            try await suite.mock(.GET, watchlistURL, result: .success(Data()), httpCode: 401)
            
            // Mock the refresh token endpoint
            let refreshTokenURL = "https://api.trakt.tv/oauth/token"
            let newTokenResponse: [String: Any] = [
                "access_token": "refreshed_access_token",
                "token_type": "bearer",
                "expires_in": 86400,
                "refresh_token": "new_refresh_token",
                "scope": "public",
                "created_at": Int(Date().timeIntervalSince1970)
            ]
            let refreshData = try JSONSerialization.data(withJSONObject: newTokenResponse)
            try await suite.mock(.POST, refreshTokenURL, result: .success(refreshData), httpCode: 200, headers: [.contentType])
            
            // Second request with new token succeeds
            let successJSON: [[String: Any]] = [
                [
                    "rank": 1,
                    "id": 12345,
                    "listed_at": "2025-02-25T12:00:00.000Z",
                    "type": "movie",
                    "movie": [
                        "title": "Watchlist Movie",
                        "year": 2025,
                        "ids": [
                            "trakt": 67890,
                            "slug": "watchlist-movie"
                        ]
                    ]
                ]
            ]
            let successData = try JSONSerialization.data(withJSONObject: successJSON)
            try await suite.mock(.GET, watchlistURL, result: .success(successData), headers: [.contentType, .apiVersion, .apiKey("test_client"), .page(1), .pageCount(1)], reusable: true)
            
            // Make request - should get 401, refresh token, and retry
            let route: Route<PagedObject<[TraktListItem]>> = Route(path: "users/me/watchlist", method: .GET, requiresAuthentication: true, traktManager: manager)
            let result = try await route.perform()
            
            // Verify request succeeded after refresh
            #expect(result.object.count == 1)
            
            // Verify token was updated
            let updatedState = try await mockAuth.getCurrentState()
            #expect(updatedState.accessToken == "refreshed_access_token")
        }
        
        @Test("Token refresh fails with invalid refresh token", .timeLimit(.minutes(1)))
        func tokenRefreshFailsWithInvalidRefreshToken() async throws {
            // Create manager with token that expires soon
            let expirationDate = Date().addingTimeInterval(1800) // 30 minutes
            let mockAuth = TraktMockAuthStorage(
                accessToken: "old_access_token",
                refreshToken: "invalid_refresh_token",
                expirationDate: expirationDate
            )
            
            let manager = await TraktManager(
                session: suite.mockSession.urlSession,
                clientId: "test_client",
                clientSecret: "test_secret",
                redirectURI: "test://redirect",
                userAgent: "myapp/1.0.0",
                authStorage: mockAuth
            )
            
            // Mock refresh endpoint returning 401 (invalid refresh token)
            let refreshTokenURL = "https://api.trakt.tv/oauth/token"
            let errorJSON: [String: Any] = ["error": "invalid_grant"]
            let errorData = try JSONSerialization.data(withJSONObject: errorJSON)
            try await suite.mock(.POST, refreshTokenURL, result: .success(errorData), httpCode: 401)
            
            // Mock the actual request (this shouldn't be reached since refresh will fail)
            let watchlistURL = "https://api.trakt.tv/sync/watchlist/movies"
            let watchlistJSON: [[String: Any]] = []
            let watchlistData = try JSONSerialization.data(withJSONObject: watchlistJSON)
            try await suite.mock(.GET, watchlistURL, result: .success(watchlistData), httpCode: 200)
            
            // Make authenticated request - should fail due to invalid refresh token
            
            await #expect(throws: TraktManager.TraktClientError.invalidRefreshToken) {
                try await manager.sync().watchlist(type: "movies").perform()
            }
        }
        
        @Test("No token refresh when token is not expiring soon", .timeLimit(.minutes(1)))
        func noRefreshWhenTokenValid() async throws {
            // Create manager with token that expires in 3 hours (well beyond 1 hour threshold)
            let expirationDate = Date().addingTimeInterval(10800) // 3 hours from now
            let mockAuth = TraktMockAuthStorage(
                accessToken: "valid_access_token",
                refreshToken: "valid_refresh_token",
                expirationDate: expirationDate
            )
            
            let manager = await TraktManager(
                session: suite.mockSession.urlSession,
                clientId: "test_client",
                clientSecret: "test_secret",
                redirectURI: "test://redirect",
                userAgent: "myapp/1.0.0",
                authStorage: mockAuth
            )
            
            // Mock only the actual request - no refresh endpoint mock
            let showsURL = "https://api.trakt.tv/shows/trending?page=1&limit=5"
            let showsJSON: [[String: Any]] = [
                [
                    "watchers": 50,
                    "show": [
                        "title": "Test Show",
                        "year": 2025,
                        "ids": [
                            "trakt": 11111,
                            "slug": "test-show"
                        ]
                    ]
                ]
            ]
            let showsData = try JSONSerialization.data(withJSONObject: showsJSON)
            try await suite.mock(.GET, showsURL, result: .success(showsData), headers: [.contentType, .apiVersion, .apiKey("test_client"), .page(1), .pageCount(1)])
            
            // Make request - should NOT trigger refresh
            let route: Route<PagedObject<[TraktTrendingShow]>> = Route(path: "shows/trending", method: .GET, traktManager: manager)
            let result = try await route.page(1).limit(5).perform()
            
            // Verify request succeeded
            #expect(result.object.count == 1)
            
            // Verify token was NOT changed
            let state = try await mockAuth.getCurrentState()
            #expect(state.accessToken == "valid_access_token")
            #expect(state.refreshToken == "valid_refresh_token")
        }
        
        @Test("Token refresh only happens once for concurrent requests", .timeLimit(.minutes(1)))
        func concurrentRequestsOnlyRefreshOnce() async throws {
            // Create manager with token that expires soon
            let expirationDate = Date().addingTimeInterval(1800) // 30 minutes
            let mockAuth = TraktMockAuthStorage(
                accessToken: "old_access_token",
                refreshToken: "valid_refresh_token",
                expirationDate: expirationDate
            )
            
            let manager = await TraktManager(
                session: suite.mockSession.urlSession,
                clientId: "test_client",
                clientSecret: "test_secret",
                redirectURI: "test://redirect",
                userAgent: "myapp/1.0.0",
                authStorage: mockAuth
            )
            
            // Mock refresh endpoint - should only be called once
            let refreshTokenURL = "https://api.trakt.tv/oauth/token"
            let newTokenResponse: [String: Any] = [
                "access_token": "new_access_token",
                "token_type": "bearer",
                "expires_in": 86400,
                "refresh_token": "new_refresh_token",
                "scope": "public",
                "created_at": Int(Date().timeIntervalSince1970)
            ]
            let refreshData = try JSONSerialization.data(withJSONObject: newTokenResponse)
            try await suite.mock(.POST, refreshTokenURL, result: .success(refreshData), httpCode: 200)
            
            // Mock authenticated endpoint (currentUser profile)
            let profileURL = "https://api.trakt.tv/users/me"
            let profileJSON: [String: Any] = [
                "username": "testuser",
                "private": false,
                "name": "Test User",
                "vip": false,
                "vip_ep": false,
                "ids": [
                    "slug": "testuser"
                ]
            ]
            let profileData = try JSONSerialization.data(withJSONObject: profileJSON)
            
            try await suite.mock(.GET, profileURL, result: .success(profileData), httpCode: 200, headers: [.contentType, .apiVersion, .apiKey("test_client")], reusable: true)
            
            // Make concurrent requests (both authenticated)
            async let user1: User = {
                return try await manager.currentUser().profile().perform()
            }()
            
            async let user2: User = {
                return try await manager.currentUser().profile().perform()
            }()
            
            // Both should succeed
            let (userResult1, userResult2) = try await (user1, user2)
            #expect(userResult1.username == "testuser")
            #expect(userResult2.username == "testuser")
            
            // Token should be refreshed
            let state = try await mockAuth.getCurrentState()
            #expect(state.accessToken == "new_access_token")
        }
    }
}
