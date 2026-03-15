//
//  RouteExtensions.swift
//  TraktKit
//
//  Trakt-specific extensions to SwiftAPIClient's Route

import Foundation
import SwiftAPIClient

// MARK: - Convenience Initializers

extension Route {

    /// Convenience initializer that accepts TraktManager
    public init(
        path: String,
        queryItems: [String: String] = [:],
        body: (any Encodable & Hashable & Sendable)? = nil,
        method: Method,
        requiresAuthentication: Bool = false,
        resultType: T.Type = T.self,
        traktManager: TraktManager
    ) {
        self.init(
            path: path,
            queryItems: queryItems,
            body: body,
            method: method,
            requiresAuthentication: requiresAuthentication,
            resultType: resultType,
            apiClient: traktManager
        )
    }

    /// Convenience initializer that accepts TraktManager and path components
    public init(
        paths: [CustomStringConvertible?],
        queryItems: [String: String] = [:],
        body: (any Encodable & Hashable & Sendable)? = nil,
        method: Method,
        requiresAuthentication: Bool = false,
        resultType: T.Type = T.self,
        traktManager: TraktManager
    ) {
        self.init(
            paths: paths,
            queryItems: queryItems,
            body: body,
            method: method,
            requiresAuthentication: requiresAuthentication,
            resultType: resultType,
            apiClient: traktManager
        )
    }
}

extension EmptyRoute {

    /// Convenience initializer that accepts TraktManager
    public init(
        path: String,
        queryItems: [String: String] = [:],
        body: (any Encodable & Hashable & Sendable)? = nil,
        method: Method,
        requiresAuthentication: Bool = false,
        traktManager: TraktManager
    ) {
        self.init(
            path: path,
            queryItems: queryItems,
            body: body,
            method: method,
            requiresAuthentication: requiresAuthentication,
            apiClient: traktManager
        )
    }

    /// Convenience initializer that accepts TraktManager and path components
    public init(
        paths: [CustomStringConvertible?],
        queryItems: [String: String] = [:],
        body: (any Encodable & Hashable & Sendable)? = nil,
        method: Method,
        requiresAuthentication: Bool = false,
        traktManager: TraktManager
    ) {
        self.init(
            paths: paths,
            queryItems: queryItems,
            body: body,
            method: method,
            requiresAuthentication: requiresAuthentication,
            apiClient: traktManager
        )
    }
}

// MARK: - Route Extensions

extension Route {

    /// Add Trakt extended info parameters
    public func extend(_ extended: ExtendedType...) -> Self {
        var copy = self
        if !extended.isEmpty {
            copy.queryItems["extended"] = extended.queryString()
        }
        return copy
    }

    /// Add Trakt filter parameters
    public func filter(_ filter: TraktManager.Filter) -> Self {
        var copy = self
        let (key, value) = filter.value()
        copy.queryItems[key] = value
        return copy
    }

    /// Add Trakt show-specific filter parameters
    public func filter(_ filter: TraktManager.ShowFilter) -> Self {
        var copy = self
        let (key, value) = filter.value()
        copy.queryItems[key] = value
        return copy
    }

    /// Add Trakt movie-specific filter parameters
    public func filter(_ filter: TraktManager.MovieFilter) -> Self {
        var copy = self
        let (key, value) = filter.value()
        copy.queryItems[key] = value
        return copy
    }

    /// Add search type parameter
    public func type(_ type: SearchType?) -> Self {
        var copy = self
        if let type {
            copy.queryItems["type"] = type.rawValue
        } else {
            copy.queryItems.removeValue(forKey: "type")
        }
        return copy
    }

    /// Add search query parameter
    public func query(_ query: String?) -> Self {
        var copy = self
        if let query {
            copy.queryItems["query"] = query
        } else {
            copy.queryItems.removeValue(forKey: "query")
        }
        return copy
    }
}

// MARK: - EmptyRoute Extensions

extension EmptyRoute {

    /// Add Trakt extended info parameters
    public func extend(_ extended: ExtendedType...) -> Self {
        var copy = self
        if !extended.isEmpty {
            copy.queryItems["extended"] = extended.queryString()
        }
        return copy
    }

    /// Add Trakt filter parameters
    public func filter(_ filter: TraktManager.Filter) -> Self {
        var copy = self
        let (key, value) = filter.value()
        copy.queryItems[key] = value
        return copy
    }

    /// Add Trakt show-specific filter parameters
    public func filter(_ filter: TraktManager.ShowFilter) -> Self {
        var copy = self
        let (key, value) = filter.value()
        copy.queryItems[key] = value
        return copy
    }

    /// Add Trakt movie-specific filter parameters
    public func filter(_ filter: TraktManager.MovieFilter) -> Self {
        var copy = self
        let (key, value) = filter.value()
        copy.queryItems[key] = value
        return copy
    }
}
