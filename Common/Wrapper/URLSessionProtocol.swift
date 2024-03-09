//
//  URLSessionProtocol.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/11/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

    func _dataTask(with request: URLRequest, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

// MARK: Conform to protocols

extension URLSession: URLSessionProtocol {

    @available(iOS, deprecated: 15.0, message: "Use the built-in API instead")
    func data(from url: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }

    public func _dataTask(with request: URLRequest, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completion) as URLSessionDataTaskProtocol
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(from: request)
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// MARK: MOCK

class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextStatusCode: Int = StatusCodes.Success
    var nextError: Error?

    private (set) var lastURL: URL?

    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: nextStatusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
    }

    public func _dataTask(with request: URLRequest, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        completion(nextData, successHttpURLResponse(request: request), nextError)
        return nextDataTask
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastURL = request.url

        if let nextData = nextData {
            return (nextData, successHttpURLResponse(request: request))
        } else if let nextError = nextError {
            throw nextError
        } else {
            fatalError("No error or data")
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private(set) var resumeWasCalled = false
    private(set) var cancelWasCalled = false

    func resume() {
        resumeWasCalled = true
    }

    func cancel() {
        cancelWasCalled = true
    }
}
