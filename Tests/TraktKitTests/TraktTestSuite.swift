//
//  TraktTestSuite.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

import Testing
import Foundation
@testable import TraktKit

@Suite
final class TraktTestSuite {
    static let traktManager = TraktManager(session: URLSession.mockedResponsesOnly, clientId: "", clientSecret: "", redirectURI: "")

    deinit {
        RequestMocking.removeAllMocks()
    }

    static func mock(_ method: TraktKit.Method, _ urlString: String, result: Result<Data, Swift.Error>, httpCode: Int? = nil, headers: [HTTPHeader] = [.contentType, .apiVersion, .apiKey("")]) throws {
        let mock = try RequestMocking.MockedResponse(urlString: urlString, result: result, httpCode: httpCode ?? method.expectedResult, headers: headers)
        RequestMocking.add(mock: mock)
    }
}
