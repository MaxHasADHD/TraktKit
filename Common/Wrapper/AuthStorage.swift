//
//  AuthStorage.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/6/25.
//
import Foundation

public struct AuthenticationState: Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expirationDate: Date

    public init(accessToken: String, refreshToken: String, expirationDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expirationDate = expirationDate
    }
}

public enum AuthenticationError: Error, Equatable {
    /// Token was found, but is past the expiration date.
    case tokenExpired(refreshToken: String)
    /// Thrown if credentials could not be retreived.
    case noStoredCredentials
}

public protocol TraktAuthentication: Sendable {
    /// Returns the current access token, refresh token, and expiration date.
    func getCurrentState() async throws(AuthenticationError) -> AuthenticationState
    /// Store the latest state
    func updateState(_ state: AuthenticationState) async
    /// Delete the data
    func clear() async
}

public actor KeychainTraktAuthentication: TraktAuthentication {
    private enum Constants {
        static let tokenExpirationDefaultsKey = "accessTokenExpirationDate"
        static let accessTokenKey = "accessToken"
        static let refreshTokenKey = "refreshToken"
    }

    private var accessToken: String?
    private var refreshToken: String?
    private var expirationDate: Date?

    public init() {
        
    }

    public func load() throws(AuthenticationError) -> AuthenticationState {
        guard
            let accessTokenData = MLKeychain.loadData(forKey: Constants.accessTokenKey),
            let accessTokenString = String(data: accessTokenData, encoding: .utf8),
            let refreshTokenData = MLKeychain.loadData(forKey: Constants.refreshTokenKey),
            let refreshTokenString = String(data: refreshTokenData, encoding: .utf8)
        else { throw .noStoredCredentials }

        accessToken = accessTokenString
        refreshToken = refreshTokenString

        // Refresh auth if expiration is not found.
        guard
            let expiration = UserDefaults.standard.object(forKey: Constants.tokenExpirationDefaultsKey) as? Date
        else { throw .tokenExpired(refreshToken: refreshTokenString) }

        expirationDate = expiration

        return AuthenticationState(accessToken: accessTokenString, refreshToken: refreshTokenString, expirationDate: expiration)
    }

    public func getCurrentState() throws(AuthenticationError) -> AuthenticationState {
        guard
            let accessToken,
            let refreshToken,
            let expirationDate
        else { return try load() }

        guard expirationDate > .now else { throw .tokenExpired(refreshToken: refreshToken) }

        return AuthenticationState(accessToken: accessToken, refreshToken: refreshToken, expirationDate: expirationDate)
    }

    public func updateState(_ state: AuthenticationState) {
        // Keep in memory
        accessToken = state.accessToken
        refreshToken = state.refreshToken

        // Save to keychain
        MLKeychain.setString(value: state.accessToken, forKey: Constants.accessTokenKey)
        MLKeychain.setString(value: state.refreshToken, forKey: Constants.refreshTokenKey)

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

    public func getCurrentState() async throws(AuthenticationError) -> AuthenticationState {
        guard
            let accessToken,
            let refreshToken,
            let expirationDate
        else { throw .noStoredCredentials }

        guard expirationDate > .now else { throw .tokenExpired(refreshToken: refreshToken) }

        return AuthenticationState(accessToken: accessToken, refreshToken: refreshToken, expirationDate: expirationDate)
    }
    
    public func updateState(_ state: AuthenticationState) async {
        accessToken = state.accessToken
        refreshToken = state.refreshToken
        expirationDate = state.expirationDate
    }
    
    public func clear() async {
        accessToken = nil
        refreshToken = nil
        expirationDate = nil
    }
}
