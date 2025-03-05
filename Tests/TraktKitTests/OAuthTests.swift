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
    @Suite
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
    }
}
