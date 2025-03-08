//
//  AuthenticationResource.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/6/25.
//

import Foundation

extension TraktManager {
    /// Endpoints for authentication
    public struct AuthenticationResource {
        private let traktManager: TraktManager
        private let path: String

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
            self.path = "oauth"
        }

        // MARK: - Authentication - OAuth

        /**
         Use the authorization `code` GET parameter sent back to your `redirect_uri` to get an `access_token`. Save the `access_token` so your app can authenticate the user by sending the `Authorization` header.

         The `access_token` is valid for **24 hours**. Save and use the `refresh_token` to get a new `access_token` without asking the user to re-authenticate.
         */
        public func getAccessToken(for code: String) -> Route<AuthenticationInfo> {
            let body = OAuthBody(
                code: code,
                clientId: traktManager.clientId,
                clientSecret: traktManager.clientSecret,
                redirectURI: traktManager.redirectURI,
                grantType: "authorization_code"
            )
            return Route(
                paths: [path, "token"],
                body: body,
                method: .POST,
                requiresAuthentication: false,
                traktManager: traktManager
            )
        }

        /**
         Use the `refresh_token` to get a new `access_token` without asking the user to re-authenticate. The `access_token` is valid for **24 hours** before it needs to be refreshed again.
         */
        public func getAccessToken(from refreshToken: String) -> Route<AuthenticationInfo> {
            let body = OAuthBody(
                refreshToken: refreshToken,
                clientId: traktManager.clientId,
                clientSecret: traktManager.clientSecret,
                redirectURI: traktManager.redirectURI,
                grantType: "refresh_token"
            )
            return Route(
                paths: [path, "token"],
                body: body,
                method: .POST,
                requiresAuthentication: false,
                traktManager: traktManager
            )
        }

        /**
         An `access_token` can be revoked when a user signs out of their Trakt account in your app. This is not required, but might improve the user experience so the user doesn't have an unused app connection hanging around.
         */
        public func revokeToken(_ accessToken: String) -> EmptyRoute {
            let body = OAuthBody(
                accessToken: accessToken,
                clientId: traktManager.clientId,
                clientSecret: traktManager.clientSecret
            )
            return EmptyRoute(
                paths: [path, "revoke"],
                body: body,
                method: .POST,
                requiresAuthentication: false,
                traktManager: traktManager
            )
        }

        // MARK: - Authentication - Devices

        /**
         Generate new codes to start the device authentication process. The `device_code` and interval will be used later to poll for the `access_token`. The `user_code` and `verification_url` should be presented to the user as mentioned in the flow steps above.

         **QR Code**

         You might consider generating a QR code for the user to easily scan on their mobile device. The QR code should be a URL that redirects to the `verification_url` and appends the `user_code`. For example, `https://trakt.tv/activate/5055CC52` would load the Trakt hosted `verification_url` and pre-fill in the `user_code`.
         */
        public func generateDeviceCode() -> Route<DeviceCode> {
            let body = OAuthBody(clientId: traktManager.clientId)
            return Route(
                paths: [path, "device", "code"],
                body: body,
                method: .POST,
                requiresAuthentication: false,
                traktManager: traktManager
            )
        }

        /**
         Use the `device_code` and poll at the `interval` (in seconds) to check if the user has authorized you app. Use `expires_in` to stop polling after that many seconds, and gracefully instruct the user to restart the process. **It is important to poll at the correct interval and also stop polling when expired.**

         When you receive a `200` success response, save the `access_token` so your app can authenticate the user in methods that require it. The `access_token` is valid for 24 hours. Save and use the `refresh_token` to get a new `access_token` without asking the user to re-authenticate. Check below for all the error codes that you should handle.

         > important: This function does **NOT** poll for the access token. This makes a single request to the endpoint and returns authentication info if available, and the status code used for polling. Use ``../TraktManager/pollForAccessToken(deviceCode:)`` to poll for the access token.
         */
        public func requestAccessToken(code: String) async throws -> (AuthenticationInfo?, Int) {
            let body = OAuthBody(
                code: code,
                clientId: traktManager.clientId,
                clientSecret: traktManager.clientSecret
            )
            let request = try traktManager.mutableRequest(forPath: "oauth/device/token", isAuthorized: false, withHTTPMethod: .POST, body: body)

            // Make response
            let (data, response) = try await traktManager.session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            // Don't throw, we want to check the `responseCode` even if the token response cannot be decoded.
            let tokenResponse = try? JSONDecoder().decode(AuthenticationInfo.self, from: data)

            return (tokenResponse, httpResponse.statusCode)
        }
    }
}
