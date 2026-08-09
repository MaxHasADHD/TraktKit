//
//  TraktResponseHandler.swift
//  TraktKit
//
//  Custom response handler for Trakt-specific HTTP status codes.
//

import Foundation
import SwiftAPIClient

/// Trakt-specific errors that extend beyond standard HTTP errors
public enum TraktAPIError: LocalizedError, Equatable {
    /// Account Limit Exceeded (420) - list count, item count, etc.
    ///
    /// A 420 has no response body; everything Trakt tells us arrives in headers.
    ///
    /// - Parameters:
    ///   - limit: The limit that was hit, from `X-Account-Limit`. `nil` when the
    ///     header is absent — unknown, *not* zero.
    ///   - isVIP: Whether the account is VIP, from `X-VIP-User`. `nil` when the
    ///     header is absent. Useful for deciding whether to show a VIP upsell.
    case accountLimitExceeded(limit: Int?, isVIP: Bool?)
    /// Trakt account locked or deactivated (423) - the user must email Trakt support.
    ///
    /// - Parameter deactivated: `true` when Trakt sent `X-Account-Deactivated`
    ///   (the account was deactivated), `false` for an ordinary lock
    ///   (`X-Account-Locked`, or no header at all). API access stays suspended
    ///   either way until Trakt resolves it.
    case accountLocked(deactivated: Bool)
    /// VIP Only (426) - User must upgrade to VIP
    case vipOnly
    /// Cloudflare Error (520/521/522) - Service unavailable due to Cloudflare
    case cloudflareError(statusCode: Int)

    public var errorDescription: String? {
        switch self {
        case .accountLimitExceeded(let limit, _):
            if let limit {
                return "Account limit exceeded. Trakt allows a maximum of \(limit) for this account."
            }
            return "Account limit exceeded. You've reached the maximum allowed items."
        case .accountLocked(let deactivated):
            if deactivated {
                return "This Trakt account has been deactivated. Email support@trakt.tv to restore access."
            }
            return "This Trakt account is locked. Email support@trakt.tv to restore access."
        case .vipOnly:
            return "This feature requires a VIP account. Please upgrade to VIP."
        case .cloudflareError(let statusCode):
            return "Service temporarily unavailable (Cloudflare error \(statusCode)). Please try again later."
        }
    }

    /// The HTTP status code associated with this error
    public var statusCode: Int {
        switch self {
        case .accountLimitExceeded: return StatusCodes.AccountLimitExceeded
        case .accountLocked: return StatusCodes.accountLocked
        case .vipOnly: return StatusCodes.vipOnly
        case .cloudflareError(let code): return code
        }
    }
}

/// Names of the Trakt response headers that carry error detail.
///
/// Trakt returns these on responses with no body (420, 423), so they are the only
/// way to tell the caller what actually happened.
enum TraktHTTPHeader {
    /// 420 — the limit that was hit.
    static let accountLimit = "X-Account-Limit"
    /// 420 — whether the account is VIP.
    static let vipUser = "X-VIP-User"
    /// 423 — the account is locked.
    static let accountLocked = "X-Account-Locked"
    /// 423 — the account is deactivated.
    static let accountDeactivated = "X-Account-Deactivated"
}

extension HTTPURLResponse {
    /// Case-insensitive header lookup parsed as an `Int`.
    /// - Returns: `nil` when the header is absent or not a number.
    func intHeaderValue(forName name: String) -> Int? {
        guard let raw = value(forHTTPHeaderField: name) else { return nil }
        return Int(raw.trimmingCharacters(in: .whitespaces))
    }

    /// Case-insensitive header lookup parsed as a `Bool`.
    ///
    /// Accepts `true`/`false`, `1`/`0`, and `yes`/`no` in any casing, since Trakt
    /// documents these headers as flags without pinning down the representation.
    /// - Returns: `nil` when the header is absent or unrecognized — never guess.
    func boolHeaderValue(forName name: String) -> Bool? {
        guard let raw = value(forHTTPHeaderField: name)?
            .trimmingCharacters(in: .whitespaces)
            .lowercased() else { return nil }
        switch raw {
        case "true", "1", "yes": return true
        case "false", "0", "no": return false
        default: return nil
        }
    }
}

/// Custom response handler for Trakt API that handles both standard HTTP errors
/// and Trakt-specific status codes
struct TraktResponseHandler: ResponseHandler {

    func handleResponse(_ response: URLResponse?) throws {
        guard let response else { return }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TraktError.unhandled(response)
        }

        // Success range - return early
        guard !(200...299 ~= httpResponse.statusCode) else {
            return
        }

        // Handle Trakt-specific status codes first
        switch httpResponse.statusCode {
        case StatusCodes.AccountLimitExceeded:
            // 420 has no body — the limit and VIP status only arrive as headers.
            throw TraktAPIError.accountLimitExceeded(
                limit: httpResponse.intHeaderValue(forName: TraktHTTPHeader.accountLimit),
                isVIP: httpResponse.boolHeaderValue(forName: TraktHTTPHeader.vipUser)
            )

        case StatusCodes.accountLocked:
            // `X-Account-Deactivated` distinguishes a deactivated account from an
            // ordinary lock (`X-Account-Locked`); both suspend API access.
            throw TraktAPIError.accountLocked(
                deactivated: httpResponse.boolHeaderValue(forName: TraktHTTPHeader.accountDeactivated) ?? false
            )

        case StatusCodes.vipOnly:
            throw TraktAPIError.vipOnly

        case StatusCodes.CloudflareError,
             StatusCodes.CloudflareError2,
             StatusCodes.CloudflareError3:
            throw TraktAPIError.cloudflareError(statusCode: httpResponse.statusCode)

        default:
            // Delegate to standard error handling for all other status codes
            try throwStandardError(for: httpResponse)
        }
    }
}
