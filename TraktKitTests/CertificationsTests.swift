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
    func testParseCertifications() {
        decode("Certifications", to: Certifications.self)
    }
}
