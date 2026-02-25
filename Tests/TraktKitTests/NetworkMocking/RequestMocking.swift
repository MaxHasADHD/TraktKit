//
//  RequestMocking.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/16/25.
//
import Foundation
import os
@testable import TraktKit
@testable import SwiftAPIClient

// MARK: - MockSession (Actor-based isolated sessions)

/// An isolated mock session for testing. Each test should create its own instance
/// to avoid interference from other tests running in parallel.
actor MockSession {
    private var mocks: [RequestMocking.MockedResponse] = []
    private let id = UUID()

    init() {
        SessionRegistry.shared.register(self, id: id)
    }

    /// Add a mock response to this session
    func add(mock: RequestMocking.MockedResponse) {
        mocks.append(mock)
    }

    /// Replace all mocks for a given URL
    func replace(mock: RequestMocking.MockedResponse) {
        mocks.removeAll(where: { $0.url == mock.url })
        mocks.append(mock)
    }

    /// Remove all mocks from this session
    func removeAllMocks() {
        mocks.removeAll()
    }

    /// Find and remove the first mock for the given request (FIFO), unless it's reusable
    func mock(for request: URLRequest) -> RequestMocking.MockedResponse? {
        guard let index = mocks.firstIndex(where: { mock in
            guard let url = request.url else { return false }
            return mock.url.compareComponents(url)
        }) else {
            return nil
        }
        let mock = mocks[index]
        if !mock.reusable {
            mocks.remove(at: index)
        }
        return mock
    }

    nonisolated func getID() -> UUID {
        return id
    }

    /// Create a URLSession configured to use this mock session
    nonisolated var urlSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [RequestMocking.self, RequestBlocking.self]
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        // Store the UUID in httpAdditionalHeaders which gets copied to requests
        configuration.httpAdditionalHeaders = ["X-Mock-ID": id.uuidString]
        return URLSession(configuration: configuration)
    }

    deinit {
        SessionRegistry.shared.unregister(id: id)
    }
}

// MARK: - Session Registry

private final class SessionRegistry: @unchecked Sendable {
    static let shared = SessionRegistry()
    private var sessions: [UUID: MockSession] = [:]
    private let lock = NSLock()

    func register(_ session: MockSession, id: UUID) {
        lock.withLock {
            sessions[id] = session
        }
    }

    func unregister(id: UUID) {
        _ = lock.withLock {
            sessions.removeValue(forKey: id)
        }
    }

    func session(for id: UUID) -> MockSession? {
        lock.withLock {
            return sessions[id]
        }
    }
}

// MARK: - RequestMocking

/// URLProtocol that works with actor-based MockSession for isolated test mocking
final class RequestMocking: URLProtocol, @unchecked Sendable {

    override class func canInit(with request: URLRequest) -> Bool {
        // Check if request has a mock session ID header
        return request.value(forHTTPHeaderField: "X-Mock-ID") != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }

    override func startLoading() {
        Task {
            guard let sessionIDString = self.request.value(forHTTPHeaderField: "X-Mock-ID"),
                  let sessionID = UUID(uuidString: sessionIDString),
                  let mockSession = SessionRegistry.shared.session(for: sessionID) else {
                self.client?.urlProtocol(self, didFailWithError: NSError(
                    domain: "MockSession",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No MockSession found"]
                ))
                return
            }

            guard let mock = await mockSession.mock(for: self.request),
                  let url = self.request.url,
                  let response = mock.customResponse ??
                    HTTPURLResponse(url: url, statusCode: mock.httpCode, httpVersion: "HTTP/1.1", headerFields: mock.headers)
            else {
                self.client?.urlProtocol(self, didFailWithError: NSError(
                    domain: "MockSession",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No mock found for URL: \(self.request.url?.absoluteString ?? "nil")"]
                ))
                return
            }

            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            switch mock.result {
            case let .success(data):
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            case let .failure(error):
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() { }
}



private extension URL {
    /// Compares components, which doesn't require query parameters to be in any particular order
    func compareComponents(_ url: URL) -> Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }

        return components.scheme == urlComponents.scheme &&
        components.host == urlComponents.host &&
        components.path == urlComponents.path &&
        components.queryItems?.enumerated().compactMap { $0.element.name }.sorted() == urlComponents.queryItems?.enumerated().compactMap { $0.element.name }.sorted() &&
        components.queryItems?.enumerated().compactMap { $0.element.value }.sorted() == urlComponents.queryItems?.enumerated().compactMap { $0.element.value }.sorted()
    }
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
