//
//  TraktResponseHandlerTests.swift
//  TraktKitTests
//
//  Tests for TraktResponseHandler and TraktAPIError
//

import Foundation
import Testing
import SwiftAPIClient
@testable import TraktKit

@Suite("TraktResponseHandler Tests")
struct TraktResponseHandlerTests {
    let handler = TraktResponseHandler()
    
    // MARK: - Success Cases
    
    @Test("Success response (200) does not throw")
    func successResponse() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: Never.self) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Success response (201) does not throw")
    func createdResponse() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: Never.self) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Success response (204) does not throw")
    func noContentResponse() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 204,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: Never.self) {
            try handler.handleResponse(response)
        }
    }
    
    // MARK: - Trakt-Specific Error Cases
    
    @Test("Account limit exceeded (420) throws TraktAPIError.accountLimitExceeded")
    func accountLimitExceeded() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.AccountLimitExceeded,
            httpVersion: nil,
            headerFields: nil
        )

        // No headers: nothing is known about the limit, and "unknown" must never
        // be mistaken for a real value.
        #expect(throws: TraktAPIError.accountLimitExceeded(limit: nil, isVIP: nil)) {
            try handler.handleResponse(response)
        }
    }

    @Test("Account limit exceeded (420) carries X-Account-Limit and X-VIP-User")
    func accountLimitExceededWithHeaders() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.AccountLimitExceeded,
            httpVersion: nil,
            headerFields: [
                "X-Account-Limit": "5",
                "X-VIP-User": "false"
            ]
        )

        #expect(throws: TraktAPIError.accountLimitExceeded(limit: 5, isVIP: false)) {
            try handler.handleResponse(response)
        }
    }

    @Test("Account limit headers are read case-insensitively")
    func accountLimitExceededHeaderCasing() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.AccountLimitExceeded,
            httpVersion: nil,
            headerFields: [
                "x-account-limit": "5000",
                "x-vip-user": "true"
            ]
        )

        #expect(throws: TraktAPIError.accountLimitExceeded(limit: 5000, isVIP: true)) {
            try handler.handleResponse(response)
        }
    }

    @Test("Account locked (423) throws TraktAPIError.accountLocked")
    func accountLocked() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.accountLocked,
            httpVersion: nil,
            headerFields: nil
        )

        #expect(throws: TraktAPIError.accountLocked(deactivated: false)) {
            try handler.handleResponse(response)
        }
    }

    @Test("Account locked (423) with X-Account-Locked reports a lock, not a deactivation")
    func accountLockedHeader() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.accountLocked,
            httpVersion: nil,
            headerFields: ["X-Account-Locked": "true"]
        )

        #expect(throws: TraktAPIError.accountLocked(deactivated: false)) {
            try handler.handleResponse(response)
        }
    }

    @Test("Account locked (423) with X-Account-Deactivated reports a deactivation")
    func accountDeactivatedHeader() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.accountLocked,
            httpVersion: nil,
            headerFields: ["X-Account-Deactivated": "true"]
        )

        #expect(throws: TraktAPIError.accountLocked(deactivated: true)) {
            try handler.handleResponse(response)
        }
    }

    @Test("Account deactivated header is read case-insensitively")
    func accountDeactivatedHeaderCasing() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.accountLocked,
            httpVersion: nil,
            headerFields: ["x-account-deactivated": "1"]
        )

        #expect(throws: TraktAPIError.accountLocked(deactivated: true)) {
            try handler.handleResponse(response)
        }
    }

    @Test("A false X-Account-Deactivated is not treated as a deactivation")
    func accountDeactivatedFalse() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.accountLocked,
            httpVersion: nil,
            headerFields: ["X-Account-Deactivated": "false"]
        )

        #expect(throws: TraktAPIError.accountLocked(deactivated: false)) {
            try handler.handleResponse(response)
        }
    }

    @Test("VIP only (426) throws TraktAPIError.vipOnly")
    func vipOnly() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.vipOnly,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktAPIError.vipOnly) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Cloudflare error (520) throws TraktAPIError.cloudflareError")
    func cloudflareError520() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.CloudflareError,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktAPIError.cloudflareError(statusCode: 520)) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Cloudflare error (521) throws TraktAPIError.cloudflareError")
    func cloudflareError521() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.CloudflareError2,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktAPIError.cloudflareError(statusCode: 521)) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Cloudflare error (522) throws TraktAPIError.cloudflareError")
    func cloudflareError522() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.CloudflareError3,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktAPIError.cloudflareError(statusCode: 522)) {
            try handler.handleResponse(response)
        }
    }
    
    // MARK: - Standard HTTP Error Cases (delegated to DefaultResponseHandler)
    
    @Test("Bad request (400) throws TraktError.badRequest")
    func badRequest() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktError.badRequest) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Unauthorized (401) throws TraktError.unauthorized")
    func unauthorized() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktError.unauthorized) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Not found (404) throws TraktError.notFound")
    func notFound() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktError.notFound) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Conflict (409) throws TraktError.conflict")
    func conflict() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 409,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktError.conflict) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Server error (500) throws TraktError.serverError")
    func serverError() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktError.serverError) {
            try handler.handleResponse(response)
        }
    }
    
    // MARK: - TraktAPIError Properties Tests
    
    @Test("TraktAPIError.accountLimitExceeded has correct statusCode")
    func accountLimitExceededStatusCode() {
        let error = TraktAPIError.accountLimitExceeded(limit: nil, isVIP: nil)
        #expect(error.statusCode == StatusCodes.AccountLimitExceeded)
        #expect(error.statusCode == 420)
    }

    @Test("TraktAPIError.accountLocked has correct statusCode")
    func accountLockedStatusCode() {
        let error = TraktAPIError.accountLocked(deactivated: false)
        #expect(error.statusCode == StatusCodes.accountLocked)
        #expect(error.statusCode == 423)
    }
    
    @Test("TraktAPIError.vipOnly has correct statusCode")
    func vipOnlyStatusCode() {
        let error = TraktAPIError.vipOnly
        #expect(error.statusCode == StatusCodes.vipOnly)
        #expect(error.statusCode == 426)
    }
    
    @Test("TraktAPIError.cloudflareError has correct statusCode")
    func cloudflareErrorStatusCode() {
        let error = TraktAPIError.cloudflareError(statusCode: 520)
        #expect(error.statusCode == 520)
    }
    
    @Test("TraktAPIError.accountLimitExceeded has error description")
    func accountLimitExceededDescription() {
        let error = TraktAPIError.accountLimitExceeded(limit: nil, isVIP: nil)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("limit") == true)
    }

    @Test("TraktAPIError.accountLimitExceeded mentions the limit when it is known")
    func accountLimitExceededDescriptionWithLimit() {
        let error = TraktAPIError.accountLimitExceeded(limit: 5, isVIP: false)
        #expect(error.errorDescription?.contains("5") == true)
    }

    @Test("TraktAPIError.accountLocked has error description")
    func accountLockedDescription() {
        let error = TraktAPIError.accountLocked(deactivated: false)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("locked") == true)
        #expect(error.errorDescription?.contains("support@trakt.tv") == true)
    }

    @Test("TraktAPIError.accountLocked distinguishes a deactivated account")
    func accountDeactivatedDescription() {
        let error = TraktAPIError.accountLocked(deactivated: true)
        #expect(error.errorDescription?.contains("deactivated") == true)
        #expect(error.errorDescription?.contains("support@trakt.tv") == true)
    }
    
    @Test("TraktAPIError.vipOnly has error description")
    func vipOnlyDescription() {
        let error = TraktAPIError.vipOnly
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("VIP") == true)
    }
    
    @Test("TraktAPIError.cloudflareError has error description with status code")
    func cloudflareErrorDescription() {
        let error = TraktAPIError.cloudflareError(statusCode: 520)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("520") == true)
        #expect(error.errorDescription?.contains("Cloudflare") == true)
    }
    
    // MARK: - Equatable Tests
    
    @Test("TraktAPIError equatable works correctly")
    func errorEquatable() {
        #expect(TraktAPIError.accountLimitExceeded(limit: 5, isVIP: false) == TraktAPIError.accountLimitExceeded(limit: 5, isVIP: false))
        #expect(TraktAPIError.accountLocked(deactivated: false) == TraktAPIError.accountLocked(deactivated: false))
        #expect(TraktAPIError.vipOnly == TraktAPIError.vipOnly)
        #expect(TraktAPIError.cloudflareError(statusCode: 520) == TraktAPIError.cloudflareError(statusCode: 520))

        #expect(TraktAPIError.accountLimitExceeded(limit: nil, isVIP: nil) != TraktAPIError.accountLocked(deactivated: false))
        #expect(TraktAPIError.accountLimitExceeded(limit: 5, isVIP: nil) != TraktAPIError.accountLimitExceeded(limit: 100, isVIP: nil))
        #expect(TraktAPIError.accountLocked(deactivated: false) != TraktAPIError.accountLocked(deactivated: true))
        #expect(TraktAPIError.cloudflareError(statusCode: 520) != TraktAPIError.cloudflareError(statusCode: 521))
    }
}
