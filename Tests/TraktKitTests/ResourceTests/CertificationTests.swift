//
//  CertificationTests.swift
//  TraktKitTests
//
//  Created by Claude Code on 2/21/26.
//

import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Certification Tests")
    struct CertificationTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        @Test func getMovieCertifications() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/certifications/movies", result: .success(jsonData(named: "test_get_certifications")))

            let certifications = try await traktManager.certifications
                .list(type: .Movies)
                .perform()

            #expect(certifications.us.count > 0)
        }

        @Test func getShowCertifications() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/certifications/shows", result: .success(jsonData(named: "test_get_certifications")))

            let certifications = try await traktManager.certifications
                .list(type: .Shows)
                .perform()

            #expect(certifications.us.count > 0)
        }
    }
}
