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
        
        #expect(throws: TraktAPIError.accountLimitExceeded) {
            try handler.handleResponse(response)
        }
    }
    
    @Test("Account locked (423) throws TraktAPIError.accountLocked")
    func accountLocked() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.trakt.tv/test")!,
            statusCode: StatusCodes.acountLocked,
            httpVersion: nil,
            headerFields: nil
        )
        
        #expect(throws: TraktAPIError.accountLocked) {
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
        let error = TraktAPIError.accountLimitExceeded
        #expect(error.statusCode == StatusCodes.AccountLimitExceeded)
        #expect(error.statusCode == 420)
    }
    
    @Test("TraktAPIError.accountLocked has correct statusCode")
    func accountLockedStatusCode() {
        let error = TraktAPIError.accountLocked
        #expect(error.statusCode == StatusCodes.acountLocked)
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
        let error = TraktAPIError.accountLimitExceeded
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("limit") == true)
    }
    
    @Test("TraktAPIError.accountLocked has error description")
    func accountLockedDescription() {
        let error = TraktAPIError.accountLocked
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("locked") == true)
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
        #expect(TraktAPIError.accountLimitExceeded == TraktAPIError.accountLimitExceeded)
        #expect(TraktAPIError.accountLocked == TraktAPIError.accountLocked)
        #expect(TraktAPIError.vipOnly == TraktAPIError.vipOnly)
        #expect(TraktAPIError.cloudflareError(statusCode: 520) == TraktAPIError.cloudflareError(statusCode: 520))
        
        #expect(TraktAPIError.accountLimitExceeded != TraktAPIError.accountLocked)
        #expect(TraktAPIError.cloudflareError(statusCode: 520) != TraktAPIError.cloudflareError(statusCode: 521))
    }
}
