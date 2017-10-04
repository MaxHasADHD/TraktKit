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
    func testParseCertificationsJSON() {
        let data = jsonData(named: "Certifications")
        
        let decoder = JSONDecoder()
        do {
            let _ = try decoder.decode(Certifications.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse certifications")
        }
    }
}
