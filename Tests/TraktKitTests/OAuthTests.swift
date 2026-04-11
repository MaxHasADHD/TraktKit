//
//  OAuthTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/5/25.
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct OAuthTests {
        let suite: TraktTestSuite

        init() async throws {
            self.suite = await TraktTestSuite()
        }
        
        // MARK: - PKCE Tests
    
    @Test func generateCodeVerifier() throws {
        let verifier = PKCEUtilities.generateCodeVerifier()
        
        // Code verifier should be 43 characters (32 bytes base64url encoded)
        #expect(verifier.count == 43)
        
        // Should only contain base64url characters (alphanumeric, -, _)
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let verifierCharacterSet = CharacterSet(charactersIn: verifier)
        #expect(allowedCharacters.isSuperset(of: verifierCharacterSet))
        
        // Should not contain padding
        #expect(!verifier.contains("="))
    }
    
    @Test func generateCodeChallenge() throws {
        let verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
        let challenge = PKCEUtilities.generateCodeChallenge(from: verifier)
        
        // Code challenge should be base64url encoded SHA256 hash (43 characters)
        #expect(challenge.count == 43)
        
        // Known test vector from RFC 7636
        // This is the expected SHA256 hash of the verifier above
        #expect(challenge == "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")
    }
    
    @Test func codeVerifierIsUnique() throws {
        let verifier1 = PKCEUtilities.generateCodeVerifier()
        let verifier2 = PKCEUtilities.generateCodeVerifier()
        
        // Each verifier should be unique
        #expect(verifier1 != verifier2)
    }
    
    @Test func base64URLEncoding() throws {
        // Test that base64url encoding properly replaces special characters
        let testData = Data([0xFF, 0xFE, 0xFD, 0xFC, 0xFB])
        let encoded = testData.base64URLEncodedString()
        
        // Should not contain standard base64 special characters
        #expect(!encoded.contains("+"))
        #expect(!encoded.contains("/"))
        #expect(!encoded.contains("="))
        
        // Should contain base64url replacements
        #expect(encoded.contains("-") || encoded.contains("_") || encoded.allSatisfy { $0.isLetter || $0.isNumber })
    }

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
    
    @Test func decodePKCETokenBody() throws {
        let json: [String: String] = [
            "code": "fd0847dbb559752d932dd3c1ac34ff98d27b11fe2fea5a864f44740cd7919ad0",
            "client_id": "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f",
            "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
            "grant_type": "authorization_code",
            "code_verifier": "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
        ]
        let data = try JSONSerialization.data(withJSONObject: json)

        let oauthBody = try JSONDecoder().decode(OAuthBody.self, from: data)
        #expect(oauthBody.code == "fd0847dbb559752d932dd3c1ac34ff98d27b11fe2fea5a864f44740cd7919ad0")
        #expect(oauthBody.refreshToken == nil)
        #expect(oauthBody.clientId == "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f")
        #expect(oauthBody.clientSecret == nil)
        #expect(oauthBody.redirectURI == "urn:ietf:wg:oauth:2.0:oob")
        #expect(oauthBody.grantType == "authorization_code")
        #expect(oauthBody.codeVerifier == "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
        #expect(oauthBody.codeChallenge == nil)
        #expect(oauthBody.codeChallengeMethod == nil)

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
        try await suite.mock(.POST, "https://api.trakt.tv/oauth/token", result: .success(data))

        let authStorage = TraktMockAuthStorage()

        let traktManager = await TraktManager(
            session: suite.mockSession.urlSession,
            clientId: "",
            clientSecret: "",
            redirectURI: "",
            userAgent: "myapp/1.0.0",
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
            session: suite.mockSession.urlSession,
            clientId: "",
            clientSecret: "",
            redirectURI: "",
            userAgent: "myapp/1.0.0",
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
        try await suite.mock(.POST, "https://api.trakt.tv/oauth/token", result: .success(data))

        // Refresh token
        try await traktManager.checkToRefresh()

        let currentAuthState = try await authStorage.getCurrentState()
        #expect(currentAuthState.accessToken == "dbaf9757982a9e738f05d249b7b5b4a266b3a139049317c4909f2f263572c781")
        #expect(traktManager.isSignedIn == true)
    }

    @Test func signOut() async throws {
        let authStorage = TraktMockAuthStorage(accessToken: "123456789", refreshToken: "abcdefgh", expirationDate: .distantFuture)

        let traktManager = await TraktManager(
            session: suite.mockSession.urlSession,
            clientId: "",
            clientSecret: "",
            redirectURI: "",
            userAgent: "myapp/1.0.0",
            authStorage: authStorage
        )
        #expect(traktManager.isSignedIn == true)
        await traktManager.signOut()
        #expect(traktManager.isSignedIn == false)
    }
    
    @Test func exchangeCodeForAccessCodeWithPKCE() async throws {
        let json: [String: Any] = [
            "access_token": "dbaf9757982a9e738f05d249b7b5b4a266b3a139049317c4909f2f263572c781",
            "token_type": "bearer",
            "expires_in": 86400,
            "refresh_token": "76ba4c5c75c96f6087f58a4de10be6c00b29ea1ddc3b2022ee2016d1363e3a7c",
            "scope": "public",
            "created_at": Date.now.timeIntervalSince1970
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        try await suite.mock(.POST, "https://api.trakt.tv/oauth/token", result: .success(data))

        let authStorage = TraktMockAuthStorage()

        let traktManager = await TraktManager(
            session: suite.mockSession.urlSession,
            clientId: "",
            redirectURI: "",
            userAgent: "myapp/1.0.0",
            authStorage: authStorage
        )
        await #expect(throws: AuthenticationError.noStoredCredentials, performing: {
            try await authStorage.getCurrentState()
        })

        let code = "..."
        let codeVerifier = PKCEUtilities.generateCodeVerifier()
        let authInfo = try await traktManager.getToken(authorizationCode: code, codeVerifier: codeVerifier)

        #expect(authInfo.accessToken == "dbaf9757982a9e738f05d249b7b5b4a266b3a139049317c4909f2f263572c781")
        #expect(authInfo.refreshToken == "76ba4c5c75c96f6087f58a4de10be6c00b29ea1ddc3b2022ee2016d1363e3a7c")
        #expect(authInfo.scope == "public")

        let currentAuthState = try await authStorage.getCurrentState()
        #expect(currentAuthState.accessToken == authInfo.accessToken)
        #expect(traktManager.isSignedIn == true)
    }
    
    @Test func generateOAuthURLWithPKCE() throws {
        let traktManager = TraktManager(
            clientId: "test_client_id",
            redirectURI: "myapp://callback",
            userAgent: "myapp/1.0.0"
        )
        
        let codeChallenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"
        let url = try #require(traktManager.oauthURL(codeChallenge: codeChallenge))
        
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        
        #expect(components.scheme == "https")
        #expect(components.host == "trakt.tv")
        #expect(components.path == "/oauth/authorize")
        
        let queryItems = try #require(components.queryItems)
        
        #expect(queryItems.contains(where: { $0.name == "response_type" && $0.value == "code" }))
        #expect(queryItems.contains(where: { $0.name == "client_id" && $0.value == "test_client_id" }))
        #expect(queryItems.contains(where: { $0.name == "redirect_uri" && $0.value == "myapp://callback" }))
        #expect(queryItems.contains(where: { $0.name == "code_challenge" && $0.value == codeChallenge }))
        #expect(queryItems.contains(where: { $0.name == "code_challenge_method" && $0.value == "S256" }))
    }
    
    @Test func refreshTokenWithPKCE() async throws {
        let refreshToken = "abcdefgh"
        // Setup Trakt Manager without client secret (PKCE mode)
        let authStorage = TraktMockAuthStorage(accessToken: "123456789", refreshToken: refreshToken, expirationDate: .distantPast)

        let traktManager = await TraktManager(
            session: suite.mockSession.urlSession,
            clientId: "",
            redirectURI: "",
            userAgent: "myapp/1.0.0",
            authStorage: authStorage
        )
        await #expect(throws: AuthenticationError.tokenExpired(refreshToken: refreshToken), performing: {
            try await authStorage.getCurrentState()
        })

        // Mock
        let json: [String: Any] = [
            "access_token": "new_access_token_from_pkce_refresh",
            "token_type": "bearer",
            "expires_in": 86400,
            "refresh_token": "new_refresh_token",
            "scope": "public",
            "created_at": Date.now.timeIntervalSince1970
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        try await suite.mock(.POST, "https://api.trakt.tv/oauth/token", result: .success(data))

        // Refresh token
        try await traktManager.checkToRefresh()

        let currentAuthState = try await authStorage.getCurrentState()
        #expect(currentAuthState.accessToken == "new_access_token_from_pkce_refresh")
        #expect(traktManager.isSignedIn == true)
    }
    
    @Test func revokeTokenBodyWithoutClientSecret() throws {
        // Test that revoke token body works without client_secret for PKCE tokens
        let json: [String: String] = [
            "token": "access_token_to_revoke",
            "client_id": "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f"
        ]
        let data = try JSONSerialization.data(withJSONObject: json)

        let oauthBody = try JSONDecoder().decode(OAuthBody.self, from: data)
        #expect(oauthBody.accessToken == "access_token_to_revoke")
        #expect(oauthBody.clientId == "9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f")
        #expect(oauthBody.clientSecret == nil)

        // To ensure `nil` keys are not encoded as empty or `null`
        let backToData = try JSONEncoder().encode(oauthBody)
        let backToJSON = try #require(JSONSerialization.jsonObject(with: backToData) as? [String: String])
        #expect(backToJSON == json)
    }
    }
}
