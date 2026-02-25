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
    /// Account Limit Exceeded (420) - list count, item count, etc
    case accountLimitExceeded
    /// Trakt account locked (423) - User must contact Trakt support
    case accountLocked
    /// VIP Only (426) - User must upgrade to VIP
    case vipOnly
    /// Cloudflare Error (520/521/522) - Service unavailable due to Cloudflare
    case cloudflareError(statusCode: Int)

    public var errorDescription: String? {
        switch self {
        case .accountLimitExceeded:
            return "Account limit exceeded. You've reached the maximum allowed items."
        case .accountLocked:
            return "Your Trakt account is locked. Please contact Trakt support at https://github.com/trakt/api-help/issues/228"
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
        case .accountLocked: return StatusCodes.acountLocked
        case .vipOnly: return StatusCodes.vipOnly
        case .cloudflareError(let code): return code
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
            throw TraktAPIError.accountLimitExceeded

        case StatusCodes.acountLocked:
            throw TraktAPIError.accountLocked

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
