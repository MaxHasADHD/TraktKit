//
//  RequestMocking.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/16/25.
//
import Foundation
import os
@testable import TraktKit

extension URLSession {
    static var mockedResponsesOnly: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [RequestMocking.self, RequestBlocking.self]
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        return URLSession(configuration: configuration)
    }
}

extension RequestMocking {
    private final class MocksContainer: @unchecked Sendable {
        var mocks: [MockedResponse] = []
    }

    static private let container = MocksContainer()
    static private let lock = NSLock()

    static func add(mock: MockedResponse) {
        lock.withLock {
            container.mocks.append(mock)
        }
    }

    static func replace(mock: MockedResponse) {
        lock.withLock {
            container.mocks.removeAll(where: { $0.url == mock.url })
            container.mocks.append(mock)
        }
    }

    static func removeAllMocks() {
        lock.withLock {
            container.mocks.removeAll()
        }
    }

    static private func mock(for request: URLRequest) -> MockedResponse? {
        return lock.withLock {
            container.mocks.first { mock in
                guard let url = request.url else { return false }
                return mock.url.compareComponents(url)
            }
        }
    }
}

// MARK: - RequestMocking

final class RequestMocking: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        return mock(for: request) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }

    override func startLoading() {
        guard
            let mock = RequestMocking.mock(for: request),
            let url = request.url,
            let response = mock.customResponse ??
                HTTPURLResponse(url: url, statusCode: mock.httpCode, httpVersion: "HTTP/1.1", headerFields: mock.headers)
        else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + mock.loadingTime) { [weak self] in
            guard let self else { return }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            switch mock.result {
            case let .success(data):
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            case let .failure(error):
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }


    override func stopLoading() { }
}

// MARK: - RequestBlocking

/// Block all outgoing requests not caught by `RequestMocking` protocol
private class RequestBlocking: URLProtocol, @unchecked Sendable {

    static let logger = Logger(subsystem: "TraktKit", category: "RequestBlocking")

    enum Error: Swift.Error {
        case requestBlocked
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        Self.logger.warning("Blocking request to \(self.request.url?.absoluteString ?? "Unknown URL.")")
        self.client?.urlProtocol(self, didFailWithError: Error.requestBlocked)
    }

    override func stopLoading() { }
}
