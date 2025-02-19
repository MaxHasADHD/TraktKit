//
//  DependencyContainer.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/9/25.
//

import Foundation

public final class DependencyContainer: @unchecked Sendable {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var _shared: DependencyContainer?

    private let instanceLock = NSLock()

    public static var shared: DependencyContainer {
        lock.withLock {
            if _shared == nil {
                _shared = DependencyContainer()
            }
            return _shared!
        }
    }

    // MARK: - Dependencies
    private var _traktClient: TraktManager

    private init() {
        self._traktClient = TraktManager.sharedManager
    }

    // MARK: - Dependency Access
    var traktClient: TraktManager {
        get { instanceLock.withLock { _traktClient } }
        set { instanceLock.withLock { _traktClient = newValue } }
    }

    // MARK: - Testing Support
    public static func reset() {
        lock.withLock {
            _shared = DependencyContainer()
        }
    }
}

@propertyWrapper
public struct InjectedClient {
    public var wrappedValue: TraktManager {
        DependencyContainer.shared.traktClient
    }

    public init() { }
}
