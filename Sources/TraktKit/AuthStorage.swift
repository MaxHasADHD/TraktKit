//
//  AuthStorage.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/6/25.
//
import Foundation
import os
import SwiftAPIClient

public protocol TraktAuthentication: APIAuthentication {}

public actor KeychainTraktAuthentication: TraktAuthentication {
    private static let logger = Logger(subsystem: "TraktKit", category: "KeychainTraktAuthentication")

    private enum Constants {
        static let tokenExpirationDefaultsKey = "accessTokenExpirationDate"
        static let accessTokenKey = "accessToken"
        static let refreshTokenKey = "refreshToken"
    }

    private var accessToken: String?
    private var refreshToken: String?
    private var expirationDate: Date?
    private var didMigrateLegacyKeychainItems = false

    public init() {

    }

    /// Tokens saved by a version of TraktKit that stored keychain items without a
    /// service attribute are moved onto the scoped service before they're read,
    /// so updating doesn't look like a sign-out. Every read path reaches `load()`,
    /// either directly or as `getCurrentState()`'s fallback.
    private func migrateLegacyKeychainItemsIfNeeded() {
        guard !didMigrateLegacyKeychainItems else { return }
        didMigrateLegacyKeychainItems = true

        MLKeychain.migrateLegacyItem(forKey: Constants.accessTokenKey)
        MLKeychain.migrateLegacyItem(forKey: Constants.refreshTokenKey)
    }

    public func load() -> AuthenticationState? {
        migrateLegacyKeychainItemsIfNeeded()

        guard
            let accessTokenData = MLKeychain.loadData(forKey: Constants.accessTokenKey),
            let accessTokenString = String(data: accessTokenData, encoding: .utf8),
            let refreshTokenData = MLKeychain.loadData(forKey: Constants.refreshTokenKey),
            let refreshTokenString = String(data: refreshTokenData, encoding: .utf8)
        else { return nil }

        accessToken = accessTokenString
        refreshToken = refreshTokenString

        // A missing expiration date means the tokens exist but we can't prove
        // they're still valid — surface that as an expired state (`distantPast`)
        // so the caller refreshes, rather than treating the user as signed out.
        let expiration = UserDefaults.standard.object(forKey: Constants.tokenExpirationDefaultsKey) as? Date ?? .distantPast

        expirationDate = expiration

        return AuthenticationState(accessToken: accessTokenString, refreshToken: refreshTokenString, expirationDate: expiration)
    }

    public func getCurrentState() -> AuthenticationState? {
        guard
            let accessToken,
            let refreshToken,
            let expirationDate
        else { return load() }

        // Return whatever credentials exist — even expired ones. The caller
        // reads `AuthenticationState.isExpired` to decide whether to refresh.
        return AuthenticationState(accessToken: accessToken, refreshToken: refreshToken, expirationDate: expirationDate)
    }

    public func updateState(_ state: AuthenticationState) {
        // Keep in memory
        accessToken = state.accessToken
        refreshToken = state.refreshToken
        expirationDate = state.expirationDate

        // Refresh tokens are single-use, so a failed write loses the replacement for a
        // token that is already spent — unrecoverable, and silent without this log.
        if !MLKeychain.setString(value: state.accessToken, forKey: Constants.accessTokenKey) {
            Self.logger.error("Failed to save access token to the keychain.")
        }
        if !MLKeychain.setString(value: state.refreshToken, forKey: Constants.refreshTokenKey) {
            Self.logger.error("Failed to save refresh token to the keychain. Syncing will fail until the user signs in again.")
        }

        UserDefaults.standard.set(state.expirationDate, forKey: Constants.tokenExpirationDefaultsKey)
    }

    public func clear() {
        accessToken = nil
        refreshToken = nil
        expirationDate = nil

        MLKeychain.deleteItem(forKey: Constants.accessTokenKey)
        MLKeychain.deleteItem(forKey: Constants.refreshTokenKey)

        UserDefaults.standard.removeObject(forKey: Constants.tokenExpirationDefaultsKey)
    }
}

public actor TraktMockAuthStorage: TraktAuthentication {

    var accessToken: String?
    var refreshToken: String?
    var expirationDate: Date?

    public init(accessToken: String? = nil, refreshToken: String? = nil, expirationDate: Date? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expirationDate = expirationDate
    }

    public func getCurrentState() -> AuthenticationState? {
        guard
            let accessToken,
            let refreshToken,
            let expirationDate
        else { return nil }

        // Return whatever credentials exist — even expired ones. The caller
        // reads `AuthenticationState.isExpired` to decide whether to refresh.
        return AuthenticationState(accessToken: accessToken, refreshToken: refreshToken, expirationDate: expirationDate)
    }

    public func updateState(_ state: AuthenticationState) {
        accessToken = state.accessToken
        refreshToken = state.refreshToken
        expirationDate = state.expirationDate
    }

    public func clear() {
        accessToken = nil
        refreshToken = nil
        expirationDate = nil
    }
}
