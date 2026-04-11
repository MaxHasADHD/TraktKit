//
//  TraktTestSuite.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

import Testing
import Foundation
@testable import TraktKit

@Suite("Endpoint Tests")
final class TraktTestSuite {
    let mockSession: MockSession
    
    init() async {
        mockSession = MockSession()
    }

    func traktManager() async -> TraktManager {
        await TraktManager(
            session: mockSession.urlSession,
            clientId: "",
            clientSecret: "",
            redirectURI: "",
            userAgent: "myapp/1.0.0",
            authStorage: TraktMockAuthStorage(accessToken: "", refreshToken: "", expirationDate: .distantFuture)
        )
    }

    func mock(
        _ method: TraktKit.Method,
        _ urlString: String,
        result: Result<Data, Swift.Error>,
        httpCode: Int? = nil,
        headers: [HTTPHeader] = [.contentType, .apiVersion, .apiKey("")],
        reusable: Bool = false
    ) async throws {
        let mock = try RequestMocking.MockedResponse(urlString: urlString, result: result, httpCode: httpCode ?? method.expectedResult, headers: headers, reusable: reusable)
        await mockSession.add(mock: mock)
    }
}
