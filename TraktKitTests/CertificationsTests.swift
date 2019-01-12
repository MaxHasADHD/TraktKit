//
//  CertificationsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 8/10/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

class CertificationsTests: XCTestCase {

    let session = MockURLSession()
    lazy var traktManager = TestTraktManager(session: session)

    override func tearDown() {
        super.tearDown()
        session.nextData = nil
        session.nextStatusCode = StatusCodes.Success
        session.nextError = nil
    }

    func test_get_certifications() {
        session.nextData = jsonData(named: "test_get_certifications")

        let expectation = XCTestExpectation(description: "Get Certifications")
        traktManager.getCertifications { result in
            if case .success(let certifications) = result {
                XCTAssertEqual(certifications.us.count, 5)
                expectation.fulfill()
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(session.lastURL?.absoluteString, "https://api.trakt.tv/certifications")

        switch result {
        case .timedOut:
            XCTFail("Something isn't working")
        default:
            break
        }
    }
}
