//
//  TraktManager.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/4/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation
import os

public extension Notification.Name {
    static let TraktAccountStatusDidChange = Notification.Name(rawValue: "signedInToTrakt")
}

public typealias TraktObject = Codable & Hashable & Sendable
public typealias EncodableTraktObject = Encodable & Hashable & Sendable

public final class TraktManager: Sendable {

    // MARK: - Types

    /// Errors related to the operation of TraktKit.
    public enum TraktKitError: Error {
        case missingClientInfo
        case malformedURL
        case userNotAuthorized
        case couldNotParseData

        // TODO: Move this enum
        case invalidRefreshToken
    }

    /// Possible errors thrown when polling for an access code.
    public enum TraktTokenError: Error {
        // 404
        case invalidDeviceCode
        // 409
        case alreadyUsed
        // 410
        case expired
        // 418
        case denied
        // 429
        case tooManyRequests
        case unexpectedStatusCode
        case missingAccessCode
    }

    // MARK: - Properties

    static let logger = Logger(subsystem: "TraktKit", category: "TraktManager")

    // MARK: Internal
    private let staging: Bool
    internal let clientId: String
    internal let clientSecret: String
    internal let redirectURI: String
    private let apiHost: String

    private let authStorage: any TraktAuthentication

    private let authStateLock = NSLock()
    nonisolated(unsafe)
    private var cachedAuthState: AuthenticationState?

    internal static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    let session: URLSession

    // MARK: Public

    public var isSignedIn: Bool {
        get {
            authStateLock.lock()
            defer { authStateLock.unlock() }
            return cachedAuthState != nil
        }
    }

    public var oauthURL: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = staging ? "staging.trakt.tv" : "trakt.tv"
        urlComponents.path = "/oauth/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
        ]
        return urlComponents.url
    }

    // MARK: - Lifecycle

    /**
     Initializes the TraktManager.

     > important: Call `refreshCurrentAuthState` shortly after initializing `TraktManager`, otherwise authenticated calls will fail.
     */
    public init(
        session: URLSession = URLSession(configuration: .default),
        staging: Bool = false,
        clientId: String,
        clientSecret: String,
        redirectURI: String,
        authStorage: any TraktAuthentication = KeychainTraktAuthentication()
    ) {
        self.session = session
        self.staging = staging
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.apiHost = staging ? "api-staging.trakt.tv" : "api.trakt.tv"
        self.authStorage = authStorage
    }

    /// Initialize TraktManager and refreshes the auth state
    public init(
        session: URLSession = URLSession(configuration: .default),
        staging: Bool = false,
        clientId: String,
        clientSecret: String,
        redirectURI: String,
        authStorage: any TraktAuthentication = KeychainTraktAuthentication()
    ) async {
        self.session = session
        self.staging = staging
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.apiHost = staging ? "api-staging.trakt.tv" : "api.trakt.tv"
        self.authStorage = authStorage

        try? await refreshCurrentAuthState()
    }

    // MARK: - Actions

    /**
     Gets the current authentication state from the authentication storage, and caches the result to make requests.
     You should only have to call this once shortly after initializing the `TraktManager`, unless you use the async initializer, which calls this function automatically.
     */
    public func refreshCurrentAuthState() async throws(AuthenticationError) {
        let currentState = try await authStorage.getCurrentState()
        authStateLock.withLock {
            cachedAuthState = currentState
        }
    }

    public func signOut() async {
        await authStorage.clear()
        authStateLock.withLock {
            cachedAuthState = nil
        }
    }

    internal func mutableRequest(
        forPath path: String,
        withQuery query: [String: String] = [:],
        isAuthorized authorized: Bool,
        withHTTPMethod httpMethod: Method,
        body: Encodable? = nil
    ) throws -> URLRequest {
        // Build URL
        let urlString = "https://\(apiHost)/" + path
        guard var components = URLComponents(string: urlString) else { throw TraktKitError.malformedURL }

        if query.isEmpty == false {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }

        guard let url = components.url else { throw TraktKitError.malformedURL }

        // Request
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        // Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue(clientId, forHTTPHeaderField: "trakt-api-key")

        if authorized {
            if let accessToken = cachedAuthState?.accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                throw TraktKitError.userNotAuthorized
            }
        }

        // Body
        if let body {
            request.httpBody = try Self.jsonEncoder.encode(body)
        }

        return request
    }

    func post<Body: Encodable>(_ path: String, query: [String: String] = [:], body: Body) throws -> URLRequest {
        try mutableRequest(forPath: path, withQuery: query, isAuthorized: true, withHTTPMethod: .POST, body: body)
    }

    // MARK: - Authentication

    public func getToken(authorizationCode code: String) async throws -> AuthenticationInfo {
        let authenticationInfo = try await auth().getAccessToken(for: code).perform()
        await saveCredentials(for: authenticationInfo, postAccountStatusChange: true)
        return authenticationInfo
    }

    // MARK: - Authentication - Devices

    /**
     Generate new codes to start the device authentication process. The `device_code` and interval will be used later to poll for the `access_token`. The `user_code` and `verification_url` should be presented to the user as mentioned in the flow steps above.

     **QR Code**

     You might consider generating a QR code for the user to easily scan on their mobile device. The QR code should be a URL that redirects to the `verification_url` and appends the `user_code`. For example, `https://trakt.tv/activate/5055CC52` would load the Trakt hosted `verification_url` and pre-fill in the `user_code`.
     */
    public func getAppCode() async throws -> DeviceCode {
        try await auth().generateDeviceCode().perform()
    }

    public func pollForAccessToken(deviceCode: DeviceCode) async throws {
        let startTime = Date()

        while true {
            let (tokenResponse, statusCode) = try await auth().requestAccessToken(code: deviceCode.deviceCode)

            switch statusCode {
            case 200:
                if let tokenResponse {
                    await saveCredentials(for: tokenResponse, postAccountStatusChange: true)
                    return
                }
                throw TraktTokenError.missingAccessCode

            case 400:
                // Pending - continue polling
                break
            case 404: throw TraktTokenError.invalidDeviceCode
            case 409: throw TraktTokenError.alreadyUsed
            case 410: throw TraktTokenError.expired
            case 418: throw TraktTokenError.denied
            case 429:
                // Too many requests - wait before polling again
                try await Task.sleep(for: .seconds(10))
                continue
            default:
                throw TraktTokenError.unexpectedStatusCode
            }

            // Stop polling if `expires_in` time has elapsed
            if Date().timeIntervalSince(startTime) >= deviceCode.expiresIn {
                throw TraktTokenError.expired
            }

            try await Task.sleep(for: .seconds(deviceCode.interval))
        }
    }

    // TODO: Find replacement for posting `TraktAccountStatusDidChange` to alert apps of account change.
    private func saveCredentials(for authInfo: AuthenticationInfo, postAccountStatusChange: Bool = false) async {
        let expiresDate = Date(timeIntervalSince1970: authInfo.createdAt).addingTimeInterval(authInfo.expiresIn)

        let authenticationState = AuthenticationState(
            accessToken: authInfo.accessToken,
            refreshToken: authInfo.refreshToken,
            expirationDate: expiresDate
        )
        await authStorage.updateState(authenticationState)
        authStateLock.withLock {
            cachedAuthState = authenticationState
        }

        // Post notification
        if postAccountStatusChange {
            await MainActor.run {
                NotificationCenter.default.post(name: .TraktAccountStatusDidChange, object: nil)
            }
        }
    }

    // MARK: Refresh access token

    public func checkToRefresh() async throws {
        do throws(AuthenticationError) {
            let currentState = try await authStorage.getCurrentState()
            authStateLock.withLock {
                cachedAuthState = currentState
            }
        } catch .tokenExpired(let refreshToken) {
            try await refreshAccessToken(with: refreshToken)
        } catch .noStoredCredentials {
            throw TraktKitError.userNotAuthorized
        }
    }

    /**
     Use the `refresh_token` to get a new `access_token` without asking the user to re-authenticate. The `access_token` is valid for 24 hours before it needs to be refreshed again.
     */
    @discardableResult
    private func refreshAccessToken(with refreshToken: String) async throws -> AuthenticationInfo {
        do {
            let authenticationInfo = try await auth().getAccessToken(from: refreshToken).perform()
            await saveCredentials(for: authenticationInfo)
            return authenticationInfo
        } catch TraktError.unauthorized { // 401 - Invalid refresh token
            throw TraktKitError.invalidRefreshToken
        } catch {
            throw error
        }
    }
}
