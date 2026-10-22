//
//  TraktEnvironmentTests.swift
//  TraktKit
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct TraktEnvironmentTests {
        let suite: TraktTestSuite

        init() async throws {
            self.suite = await TraktTestSuite()
        }

        private static let custom = TraktEnvironment(
            apiURL: URL(string: "http://127.0.0.1:8080/api")!,
            authURL: URL(string: "http://127.0.0.1:8080/auth")!
        )

        private func manager(_ environment: TraktEnvironment, authStorage: TraktMockAuthStorage = TraktMockAuthStorage()) async -> TraktManager {
            await TraktManager(
                session: suite.mockSession.urlSession,
                environment: environment,
                clientId: "client",
                redirectURI: "myapp://callback",
                userAgent: "myapp/1.0.0",
                authStorage: authStorage
            )
        }

        private static var tokenJSON: [String: Any] {
            [
                "access_token": "new-access",
                "token_type": "bearer",
                "expires_in": 604800,
                "refresh_token": "new-refresh",
                "scope": "public",
                "created_at": Date.now.timeIntervalSince1970
            ]
        }

        @Test func production() {
            #expect(TraktEnvironment.production.apiURL.absoluteString == "https://api.trakt.tv")
            #expect(TraktEnvironment.production.authURL.absoluteString == "https://auth.trakt.tv")
        }

        /// Premium apps call another API host with the same paths and headers, and sign in like any other.
        @Test func premium() {
            #expect(TraktEnvironment.premium.apiURL.absoluteString == "https://apiz.trakt.tv")
            #expect(TraktEnvironment.premium.authURL == TraktEnvironment.production.authURL)
        }

        @Test func productionIsTheDefault() {
            let traktManager = TraktManager(clientId: "client", redirectURI: "myapp://callback", userAgent: "myapp/1.0.0")
            #expect(traktManager.environment == .production)
            #expect(traktManager.configuration.baseURL == TraktEnvironment.production.apiURL)
        }

        @Test func apiRequestsGoToTheAPIURL() async throws {
            try await suite.mock(.GET, "http://127.0.0.1:8080/api/shows/trending?page=1&limit=10", result: .success(Data("[]".utf8)))

            let shows = try await manager(Self.custom).shows.trending().page(1).limit(10).perform()

            #expect(shows.object.isEmpty)
        }

        @Test func signInGoesToTheAuthURL() async throws {
            try await suite.mock(.POST, "http://127.0.0.1:8080/auth/oauth/token", result: .success(JSONSerialization.data(withJSONObject: Self.tokenJSON)))

            let authInfo = try await manager(Self.custom).getToken(authorizationCode: "code", codeVerifier: "verifier")

            #expect(authInfo.accessToken == "new-access")
        }

        @Test func tokenRefreshGoesToTheAuthURL() async throws {
            try await suite.mock(.POST, "http://127.0.0.1:8080/auth/oauth/token", result: .success(JSONSerialization.data(withJSONObject: Self.tokenJSON)))
            let authStorage = TraktMockAuthStorage(accessToken: "old-access", refreshToken: "old-refresh", expirationDate: .distantPast)
            let traktManager = await manager(Self.custom, authStorage: authStorage)

            try await traktManager.refreshTokenIfNeeded()

            #expect(await authStorage.getCurrentState()?.accessToken == "new-access")
        }

        @Test func revokeGoesToTheAuthURL() async throws {
            try await suite.mock(.POST, "http://127.0.0.1:8080/auth/oauth/revoke", result: .success(Data()), httpCode: 200)

            try await manager(Self.custom).auth().revokeToken("access").perform()
        }

        @Test func deviceCodeGoesToTheAuthURL() async throws {
            let json: [String: Any] = [
                "device_code": "device",
                "user_code": "5055CC52",
                "verification_url": "https://trakt.tv/activate",
                "expires_in": 600,
                "interval": 5
            ]
            try await suite.mock(.POST, "http://127.0.0.1:8080/auth/oauth/device/code", result: .success(JSONSerialization.data(withJSONObject: json)), httpCode: 200)

            let code = try await manager(Self.custom).getAppCode()

            #expect(code.userCode == "5055CC52")
        }

        @Test func deviceTokenGoesToTheAuthURL() async throws {
            try await suite.mock(.POST, "http://127.0.0.1:8080/auth/oauth/device/token", result: .success(JSONSerialization.data(withJSONObject: Self.tokenJSON)), httpCode: 200)

            let (authInfo, statusCode) = try await manager(Self.custom).auth().requestAccessToken(code: "device")

            #expect(statusCode == 200)
            #expect(authInfo?.accessToken == "new-access")
        }

        /// The sign-in page takes its scheme, host, port and path from the auth URL.
        @Test func signInPage() async throws {
            let traktManager = await manager(Self.custom)

            let url = try #require(traktManager.oauthURL(codeChallenge: "challenge"))
            let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
            #expect(components.scheme == "http")
            #expect(components.host == "127.0.0.1")
            #expect(components.port == 8080)
            #expect(components.path == "/auth/oauth/authorize")
            #expect(components.queryItems?.contains(URLQueryItem(name: "code_challenge", value: "challenge")) == true)

            let withoutPKCE = try #require(traktManager.oauthURL)
            #expect(withoutPKCE.absoluteString.hasPrefix("http://127.0.0.1:8080/auth/oauth/authorize?"))
        }
    }
}
