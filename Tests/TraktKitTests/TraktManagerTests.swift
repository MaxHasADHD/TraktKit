//
//  TraktManagerTests.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/8/25.
//

import Foundation
import Testing
@testable import TraktKit

@Suite
class TraktManagerTests {

    lazy var traktManager = TraktManager(session: URLSession.mockedResponsesOnly, clientId: "", clientSecret: "", redirectURI: "")

    deinit {
        RequestMocking.removeAllMocks()
    }

    @Test
    func pollForAccessTokenInvalidDeviceCode() async throws {
        let mock = try RequestMocking.MockedResponse(urlString: "https://api.trakt.tv/oauth/device/token", result: .success(.init()), httpCode: 404)
        RequestMocking.add(mock: mock)

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
}
