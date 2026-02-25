//
//  SwiftAPIClientTypealiases.swift
//  TraktKit
//
//  Re-exports SwiftAPIClient types for backward compatibility and convenience.
//

import Foundation
import SwiftAPIClient

// MARK: - Core Types

public typealias TraktObject = Codable & Hashable & Sendable
public typealias EncodableTraktObject = Encodable & Hashable & Sendable

// MARK: - SwiftAPIClient Re-exports

public typealias Method = SwiftAPIClient.Method
/// Standard HTTP errors from SwiftAPIClient. For Trakt-specific errors (420, 423, 426, 520-522),
/// catch `TraktAPIError` instead.
public typealias TraktError = SwiftAPIClient.APIError
public typealias AuthenticationState = SwiftAPIClient.AuthenticationState
public typealias AuthenticationError = SwiftAPIClient.AuthenticationError
public typealias PagedObjectProtocol = SwiftAPIClient.PagedObjectProtocol
public typealias PagedObject = SwiftAPIClient.PagedObject
