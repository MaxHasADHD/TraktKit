//
//  TraktTestCase.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/16/25.
//

import XCTest
@testable import TraktKit

class TraktTestCase: XCTestCase {
    lazy var traktManager = TraktManager(
        session: URLSession.mockedResponsesOnly,
        clientId: "",
        clientSecret: "",
        redirectURI: "",
        authStorage: TraktMockAuthStorage(accessToken: "", refreshToken: "", expirationDate: .distantFuture)
    )

    override func setUp() async throws {
        try await traktManager.refreshCurrentAuthState()
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }

    func mock(_ method: TraktKit.Method, _ urlString: String, result: Result<Data, Swift.Error>, httpCode: Int? = nil, headers: [HTTPHeader] = [.contentType, .apiVersion, .apiKey("")]) throws {
        let mock = try RequestMocking.MockedResponse(urlString: urlString, result: result, httpCode: httpCode ?? method.expectedResult, headers: headers)
        RequestMocking.add(mock: mock)
    }
}
