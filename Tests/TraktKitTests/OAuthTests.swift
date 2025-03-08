//
//  OAuthTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/5/25.
//

import Foundation
import Testing
@testable import TraktKit

@Suite(.serialized)
struct OAuthTests {

    @Test func decodeOAuthTokenBody() throws {
        let json: [String: String] = [
            "code": "fd0847dbb559752d932dd3c1ac34ff98d27b11fe2fea5a864f44740cd7919ad0",
            "client_id": "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f",
            "client_secret": "d6ea27703957b69939b8104ed4524595e210cd2e79af587744a7eb6e58f5b3d2",
            "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
            "grant_type": "authorization_code"
        ]
        let data = try JSONSerialization.data(withJSONObject: json)

        let oauthBody = try JSONDecoder().decode(OAuthBody.self, from: data)
        #expect(oauthBody.code == "fd0847dbb559752d932dd3c1ac34ff98d27b11fe2fea5a864f44740cd7919ad0")
        #expect(oauthBody.refreshToken == nil)
        #expect(oauthBody.clientId == "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f")
        #expect(oauthBody.clientSecret == "d6ea27703957b69939b8104ed4524595e210cd2e79af587744a7eb6e58f5b3d2")
        #expect(oauthBody.redirectURI == "urn:ietf:wg:oauth:2.0:oob")
        #expect(oauthBody.grantType == "authorization_code")

        // To ensure `nil` keys are not encoded as empty or `null`
        let backToData = try JSONEncoder().encode(oauthBody)
        let backToJSON = try #require(JSONSerialization.jsonObject(with: backToData) as? [String: String])
        #expect(backToJSON == json)
    }

    @Test func decodeRefreshTokenBody() throws {
        let json: [String: String] = [
            "refresh_token": "fd0847dbb559752d932dd3c1ac34ff98d27b11fe2fea5a864f44740cd7919ad0",
            "client_id": "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f",
            "client_secret": "d6ea27703957b69939b8104ed4524595e210cd2e79af587744a7eb6e58f5b3d2",
            "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
            "grant_type": "refresh_token"
        ]
        let data = try JSONSerialization.data(withJSONObject: json)

        let oauthBody = try JSONDecoder().decode(OAuthBody.self, from: data)
        #expect(oauthBody.code == nil)
        #expect(oauthBody.refreshToken == "fd0847dbb559752d932dd3c1ac34ff98d27b11fe2fea5a864f44740cd7919ad0")
        #expect(oauthBody.clientId == "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f")
        #expect(oauthBody.clientSecret == "d6ea27703957b69939b8104ed4524595e210cd2e79af587744a7eb6e58f5b3d2")
        #expect(oauthBody.redirectURI == "urn:ietf:wg:oauth:2.0:oob")
        #expect(oauthBody.grantType == "refresh_token")

        // To ensure `nil` keys are not encoded as empty or `null`
        let backToData = try JSONEncoder().encode(oauthBody)
        let backToJSON = try #require(JSONSerialization.jsonObject(with: backToData) as? [String: String])
        #expect(backToJSON == json)
    }

    @Test func decodeDeviceTokenBody() throws {
        let json: [String: String] = [
            "client_id": "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f"
        ]
        let data = try JSONSerialization.data(withJSONObject: json)

        let oauthBody = try JSONDecoder().decode(OAuthBody.self, from: data)
        #expect(oauthBody.code == nil)
        #expect(oauthBody.refreshToken == nil)
        #expect(oauthBody.clientId == "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f")
        #expect(oauthBody.clientSecret == nil)
        #expect(oauthBody.redirectURI == nil)
        #expect(oauthBody.grantType == nil)

        // To ensure `nil` keys are not encoded as empty or `null`
        let backToData = try JSONEncoder().encode(oauthBody)
        let backToJSON = try #require(JSONSerialization.jsonObject(with: backToData) as? [String: String])
        #expect(backToJSON == json)
    }

    // MARK: - Networking

    @Test func exchangeCodeForAccessCode() async throws {
        let json: [String: Any] = [
            "access_token": "dbaf9757982a9e738f05d249b7b5b4a266b3a139049317c4909f2f263572c781",
            "token_type": "bearer",
            "expires_in": 86400,
            "refresh_token": "76ba4c5c75c96f6087f58a4de10be6c00b29ea1ddc3b2022ee2016d1363e3a7c",
            "scope": "public",
            "created_at": Date.now.timeIntervalSince1970
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        try OAuthTests.mock(.POST, "https://api.trakt.tv/oauth/token", result: .success(data), replace: true)

        let authStorage = TraktMockAuthStorage()

        let traktManager = await TraktManager(
            session: URLSession.mockedResponsesOnly,
            clientId: "",
            clientSecret: "",
            redirectURI: "",
            authStorage: authStorage
        )
        await #expect(throws: AuthenticationError.noStoredCredentials, performing: {
            try await authStorage.getCurrentState()
        })

        let code = "..."
        let authInfo = try await traktManager.getToken(authorizationCode: code)

        #expect(authInfo.accessToken == "dbaf9757982a9e738f05d249b7b5b4a266b3a139049317c4909f2f263572c781")
        #expect(authInfo.refreshToken == "76ba4c5c75c96f6087f58a4de10be6c00b29ea1ddc3b2022ee2016d1363e3a7c")
        #expect(authInfo.scope == "public")

        let currentAuthState = try await authStorage.getCurrentState()
        #expect(currentAuthState.accessToken == authInfo.accessToken)
        #expect(traktManager.isSignedIn == true)
    }

    @Test func exchangeRefreshTokenForAccessCode() async throws {
        let refreshToken = "abcdefgh"
        // Setup Trakt Manager with expired token
        let authStorage = TraktMockAuthStorage(accessToken: "123456789", refreshToken: refreshToken, expirationDate: .distantPast)

        let traktManager = await TraktManager(
            session: URLSession.mockedResponsesOnly,
            clientId: "",
            clientSecret: "",
            redirectURI: "",
            authStorage: authStorage
        )
        await #expect(throws: AuthenticationError.tokenExpired(refreshToken: refreshToken), performing: {
            try await authStorage.getCurrentState()
        })

        // Mock
        let json: [String: Any] = [
            "access_token": "dbaf9757982a9e738f05d249b7b5b4a266b3a139049317c4909f2f263572c781",
            "token_type": "bearer",
            "expires_in": 86400,
            "refresh_token": "76ba4c5c75c96f6087f58a4de10be6c00b29ea1ddc3b2022ee2016d1363e3a7c",
            "scope": "public",
            "created_at": Date.now.timeIntervalSince1970
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        try OAuthTests.mock(.POST, "https://api.trakt.tv/oauth/token", result: .success(data), replace: true)

        // Refresh token
        try await traktManager.checkToRefresh()

        let currentAuthState = try await authStorage.getCurrentState()
        #expect(currentAuthState.accessToken == "dbaf9757982a9e738f05d249b7b5b4a266b3a139049317c4909f2f263572c781")
        #expect(traktManager.isSignedIn == true)
    }

    @Test func signOut() async throws {
        let authStorage = TraktMockAuthStorage(accessToken: "123456789", refreshToken: "abcdefgh", expirationDate: .distantFuture)

        let traktManager = await TraktManager(
            session: URLSession.mockedResponsesOnly,
            clientId: "",
            clientSecret: "",
            redirectURI: "",
            authStorage: authStorage
        )
        #expect(traktManager.isSignedIn == true)
        await traktManager.signOut()
        #expect(traktManager.isSignedIn == false)
    }

    // MARK: - Helper

    static func mock(_ method: TraktKit.Method, _ urlString: String, result: Result<Data, Swift.Error>, httpCode: Int? = nil, headers: [HTTPHeader] = [.contentType, .apiVersion, .apiKey("")], replace: Bool = false) throws {
        let mock = try RequestMocking.MockedResponse(urlString: urlString, result: result, httpCode: httpCode ?? method.expectedResult, headers: headers)
        if replace {
            RequestMocking.replace(mock: mock)
        } else {
            RequestMocking.add(mock: mock)
        }
    }
}
