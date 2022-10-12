//
//  TestTraktManager.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 1/12/19.
//  Copyright © 2019 Maximilian Litteral. All rights reserved.
//

@testable import TraktKit

final class TestTraktManager: TraktManager {
    override init(session: URLSessionProtocol) {
        super.init(session: session)
        self.set(clientID: "", clientSecret: "", redirectURI: "", staging: false)
    }
}
