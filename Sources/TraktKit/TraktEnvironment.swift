//
//  TraktEnvironment.swift
//  TraktKit
//

import Foundation

/// Where a `TraktManager` sends its requests. Trakt serves its API and its sign-in from separate hosts,
/// so there are two URLs.
///
/// Use `.production`, or `.premium` for apps on Trakt's Developer Premium plan. Any other server that
/// speaks Trakt's API, such as a proxy, can be given with `init(apiURL:authURL:)`.
public struct TraktEnvironment: Sendable, Hashable {

    /// Every API request.
    public var apiURL: URL

    /// Every OAuth request: the sign-in page, exchanging and refreshing tokens, revoking a token, and
    /// device authentication.
    public var authURL: URL

    public init(apiURL: URL, authURL: URL) {
        self.apiURL = apiURL
        self.authURL = authURL
    }

    public static let production = TraktEnvironment(
        apiURL: URL(string: "https://api.trakt.tv")!,
        authURL: URL(string: "https://auth.trakt.tv")!
    )

    /// Higher rate limits for apps on Trakt's Developer Premium plan. The paths and headers are the same
    /// as production, and Trakt rejects apps that aren't on the plan.
    public static let premium = TraktEnvironment(
        apiURL: URL(string: "https://apiz.trakt.tv")!,
        authURL: URL(string: "https://auth.trakt.tv")!
    )
}
