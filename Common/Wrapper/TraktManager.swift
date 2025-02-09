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

@preconcurrency
public class TraktManager {

    // TODO List:
    // 1. Create a limit object, double check every paginated API call is marked as paginated
    // 2. Call completion with custom error when creating request fails

    // MARK: - Types

    public enum TraktKitError: Error {
        case missingClientInfo
        case malformedURL
        case userNotAuthorized
        case couldNotParseData
        case invalidRefreshToken
    }

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

    public enum RefreshState {
        case noTokens, validTokens, refreshTokens, expiredTokens
    }

    /// Returns the local token state. This could be wrong if a user revokes application access from Trakt.tv
    public var refreshState: RefreshState {
        guard let expiredDate = UserDefaults.standard.object(forKey: Constants.tokenExpirationDefaultsKey) as? Date else {
            return .noTokens
        }
        let refreshDate = expiredDate.addingTimeInterval(-Constants.oneMonth)
        let now = Date()

        if now >= expiredDate {
            return .expiredTokens
        }

        if now >= refreshDate {
            return .refreshTokens
        }

        return .validTokens
    }

    // MARK: - Properties

    private enum Constants {
        static let tokenExpirationDefaultsKey = "accessTokenExpirationDate"
        static let oneMonth: TimeInterval = 2629800
    }

    static let logger = Logger(subsystem: "TraktKit", category: "TraktManager")

    // MARK: Internal
    private var staging: Bool?
    private var clientID: String?
    private var clientSecret: String?
    private var redirectURI: String?
    private var baseURL: String?
    private var APIBaseURL: String?
    private var isWaitingToToken: Bool = false
    let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // Keys
    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"

    let session: URLSessionProtocol

    public lazy var explore: ExploreResource = ExploreResource(traktManager: self)

    // MARK: Public

    @preconcurrency
    public static let sharedManager = TraktManager()

    public var isSignedIn: Bool {
        get {
            return accessToken != nil
        }
    }
    public var oauthURL: URL?

    private var _accessToken: String?
    public var accessToken: String? {
        get {
            if _accessToken != nil {
                return _accessToken
            }
            if let accessTokenData = MLKeychain.loadData(forKey: accessTokenKey) {
                if let accessTokenString = String(data: accessTokenData, encoding: .utf8) {
                    _accessToken = accessTokenString
                    return accessTokenString
                }
            }

            return nil
        }
        set {
            // Save somewhere secure
            _accessToken = newValue
            if newValue == nil {
                // Remove from keychain
                MLKeychain.deleteItem(forKey: accessTokenKey)
            } else {
                // Save to keychain
                let succeeded = MLKeychain.setString(value: newValue!, forKey: accessTokenKey)
                Self.logger.debug("Saved access token \(succeeded ? "successfully" : "failed")")
            }
        }
    }

    private var _refreshToken: String?
    public var refreshToken: String? {
        get {
            if _refreshToken != nil {
                return _refreshToken
            }
            if let refreshTokenData = MLKeychain.loadData(forKey: refreshTokenKey) {
                if let refreshTokenString = String.init(data: refreshTokenData, encoding: .utf8) {
                    _refreshToken = refreshTokenString
                    return refreshTokenString
                }
            }

            return nil
        }
        set {
            // Save somewhere secure
            _refreshToken = newValue
            if newValue == nil {
                // Remove from keychain
                MLKeychain.deleteItem(forKey: refreshTokenKey)
            } else {
                // Save to keychain
                let succeeded = MLKeychain.setString(value: newValue!, forKey: refreshTokenKey)
                Self.logger.debug("Saved refresh token \(succeeded ? "successfully" : "failed")")
            }
        }
    }

    // MARK: - Lifecycle

    public init(session: URLSessionProtocol = URLSession(configuration: .default)) {
        self.session = session
    }

    // MARK: - Setup

    public func set(clientID: String, clientSecret secret: String, redirectURI: String, staging: Bool = false) {
        self.clientID = clientID
        self.clientSecret = secret
        self.redirectURI = redirectURI
        self.staging = staging

        self.baseURL = !staging ? "trakt.tv" : "staging.trakt.tv"
        self.APIBaseURL = !staging ? "api.trakt.tv" : "api-staging.trakt.tv"
        self.oauthURL = URL(string: "https://\(baseURL!)/oauth/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)")
    }

    internal func createErrorWithStatusCode(_ statusCode: Int) -> NSError {
        let message = if let traktMessage = StatusCodes.message(for: statusCode) {
            traktMessage
        } else {
            "Request Failed: Gateway timed out (\(statusCode))"
        }

        let userInfo = [
            "title": "Error",
            NSLocalizedDescriptionKey: message,
            NSLocalizedFailureReasonErrorKey: "",
            NSLocalizedRecoverySuggestionErrorKey: ""
        ]
        return NSError(domain: "com.litteral.TraktKit", code: statusCode, userInfo: userInfo)
    }

    // MARK: - Actions

    public func signOut() {
        accessToken = nil
        refreshToken = nil
        UserDefaults.standard.removeObject(forKey: Constants.tokenExpirationDefaultsKey)
    }

    internal func mutableRequestForURL(_ url: URL, authorization: Bool, HTTPMethod: Method) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.rawValue

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        if let clientID {
            request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        }

        if authorization {
            if let accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                throw TraktKitError.userNotAuthorized
            }
        }

        return request
    }

    internal func mutableRequest(forPath path: String, withQuery query: [String: String], isAuthorized authorized: Bool, withHTTPMethod httpMethod: Method) throws -> URLRequest? {
        guard let apiBaseURL = APIBaseURL else { throw TraktKitError.missingClientInfo }
        let urlString = "https://\(apiBaseURL)/" + path
        guard var components = URLComponents(string: urlString) else { return nil }

        if query.isEmpty == false {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }

        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        if let clientID = clientID {
            request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        }

        if authorized {
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        }

        return request
    }

    func post<Body: Encodable>(_ path: String, query: [String: String] = [:], body: Body) -> URLRequest? {
        guard let apiBaseURL = APIBaseURL else { preconditionFailure("Call `set(clientID:clientSecret:redirectURI:staging:)` before making any API requests") }
        let urlString = "https://\(apiBaseURL)/" + path
        guard var components = URLComponents(string: urlString) else { return nil }
        if query.isEmpty == false {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }

        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = Method.POST.rawValue

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        if let clientID = clientID {
            request.addValue(clientID, forHTTPHeaderField: "trakt-api-key")
        }

        if let accessToken = accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try jsonEncoder.encode(body)
        } catch {
            return nil
        }
        return request
    }

    // MARK: - Authentication

    public func getToken(authorizationCode code: String) async throws -> AuthenticationInfo {
        guard
            let baseURL,
            let clientID,
            let clientSecret,
            let redirectURI = redirectURI
        else {
            throw TraktKitError.missingClientInfo
        }

        let urlString = "https://\(baseURL)/oauth/token"
        guard let url = URL(string: urlString) else {
            throw TraktKitError.malformedURL
        }
        var request = try mutableRequestForURL(url, authorization: false, HTTPMethod: .POST)

        let json = [
            "code": code,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])

        let authenticationInfo: AuthenticationInfo = try await perform(request: request)
        await saveCredentials(for: authenticationInfo, postAccountStatusChange: true)
        return authenticationInfo
    }

    // MARK: - Authentication - Devices

    public func getAppCode() async throws -> DeviceCode {
        guard
            let APIBaseURL,
            let clientID
        else {
            throw TraktKitError.missingClientInfo
        }
        let urlString = "https://\(APIBaseURL)/oauth/device/code/"

        guard let url = URL(string: urlString) else {
            throw TraktKitError.malformedURL
        }
        let json = ["client_id": clientID]

        var request = try mutableRequestForURL(url, authorization: false, HTTPMethod: .POST)
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])

        return try await perform(request: request)
    }

    public func pollForAccessToken(deviceCode: DeviceCode) async throws {
        let startTime = Date()

        while true {
            let (tokenResponse, statusCode) = try await requestAccessToken(code: deviceCode.deviceCode)

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

    private func requestAccessToken(code: String) async throws -> (AuthenticationInfo?, Int) {
        // Build request
        guard
            let APIBaseURL,
            let clientID,
            let clientSecret
        else {
            throw TraktKitError.missingClientInfo
        }

        let urlString = "https://\(APIBaseURL)/oauth/device/token"
        guard let url = URL(string: urlString) else {
            throw TraktKitError.malformedURL
        }
        var request = try mutableRequestForURL(url, authorization: false, HTTPMethod: .POST)

        let json = [
            "code": code,
            "client_id": clientID,
            "client_secret": clientSecret,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])

        // Make response
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Don't throw, we want to check the `responseCode` even if the token response cannot be decoded.
        let tokenResponse = try? JSONDecoder().decode(AuthenticationInfo.self, from: data)

        return (tokenResponse, httpResponse.statusCode)
    }

    // TODO: Find replacement for posting `TraktAccountStatusDidChange` to alert apps of account change.
    private func saveCredentials(for authInfo: AuthenticationInfo, postAccountStatusChange: Bool = false) async {
        self.accessToken = authInfo.accessToken
        self.refreshToken = authInfo.refreshToken

        // Save expiration date
        let expiresDate = Date(timeIntervalSinceNow: authInfo.expiresIn)
        UserDefaults.standard.set(expiresDate, forKey: "accessTokenExpirationDate")
        UserDefaults.standard.synchronize()

        // Post notification
        if postAccountStatusChange {
            await MainActor.run {
                NotificationCenter.default.post(name: .TraktAccountStatusDidChange, object: nil)
            }
        }
    }

    // MARK: Refresh access token

    public func checkToRefresh() async throws {
        switch refreshState {
        case .refreshTokens:
            try await getAccessTokenFromRefreshToken()
        case .expiredTokens:
            throw TraktKitError.invalidRefreshToken
        default:
            break
        }
    }

    /**
     Use the `refresh_token` to get a new `access_token` without asking the user to re-authenticate. The `access_token` is valid for 24 hours before it needs to be refreshed again.
     */
    public func getAccessTokenFromRefreshToken() async throws {
        guard
            let baseURL,
            let clientID,
            let clientSecret,
            let redirectURI
        else {
            throw TraktKitError.missingClientInfo
        }

        guard let refreshToken else { throw TraktKitError.invalidRefreshToken }

        // Create request
        guard let url = URL(string: "https://\(baseURL)/oauth/token") else {
            throw TraktKitError.malformedURL
        }
        var request = try mutableRequestForURL(url, authorization: false, HTTPMethod: .POST)

        let json = [
            "refresh_token": refreshToken,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "refresh_token",
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])

        // Make request and handle response
        do {
            let authenticationInfo: AuthenticationInfo = try await perform(request: request)
            await saveCredentials(for: authenticationInfo)
        } catch TraktError.unauthorized {
            throw TraktKitError.invalidRefreshToken
        } catch {
            throw error
        }
    }
}
