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
}

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

// MARK: Conform to protocols

extension URLSession: URLSessionProtocol {
    public func _dataTask(with request: URLRequest, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completion) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// MARK: MOCK

public class MockURLSession: URLSessionProtocol {
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
