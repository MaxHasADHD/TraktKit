//
//  MockedResponse.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/16/25.
//

import Foundation
@testable import TraktKit

extension RequestMocking {
    struct MockedResponse {
        let url: URL
        let result: Result<Data, Swift.Error>
        let httpCode: Int
        let headers: [String: String]
        let loadingTime: TimeInterval
        let customResponse: URLResponse?
    }
}

extension RequestMocking.MockedResponse {
    enum Error: Swift.Error {
        case failedMockCreation
    }

    init(urlString: String, result: Result<Data, Swift.Error>, httpCode: Int = 200, headers: [HTTPHeader] = [.contentType, .apiVersion, .apiKey("")], loadingTime: TimeInterval = .zero) throws {
        guard let url = URL(string: urlString) else { throw Error.failedMockCreation }
        self.url = url
        self.result = result
        self.httpCode = httpCode
        self.headers = Dictionary(headers.map { ($0.key, $0.value) }) { _, last in last }
        self.loadingTime = loadingTime
        self.customResponse = nil
    }
}
