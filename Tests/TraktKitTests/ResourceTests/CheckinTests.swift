//
//  CheckinTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/24/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Testing
import Foundation
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Checkin Tests")
    struct CheckinTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        @Test func checkinMovie() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/checkin", result: .success(jsonData(named: "test_checkin_movie")))

            let checkin = try await traktManager.checkin()
                .checkInto(movie: SyncId(trakt: 12345))
                .perform()

            #expect(checkin.id == 3373536619)
            #expect(checkin.movie != nil)
        }

        @Test func checkinEpisode() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/checkin", result: .success(jsonData(named: "test_checkin_episode")))

            let checkin = try await traktManager.checkin()
                .checkInto(episode: SyncId(trakt: 12345))
                .perform()

            #expect(checkin.id == 3373536620)
            #expect(checkin.episode != nil)
            #expect(checkin.show != nil)
        }

        @Test func alreadyCheckedIn() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/checkin", result: .success(jsonData(named: "test_already_checked_in")), httpCode: StatusCodes.Conflict)

            await #expect(throws: TraktError.conflict) {
                try await traktManager.checkin()
                    .checkInto(episode: SyncId(trakt: 12345))
                    .perform()
            }
        }

        @Test func deleteActiveCheckins() async throws {
            try await suite.mock(.DELETE, "https://api.trakt.tv/checkin", result: .success(.init()), httpCode: StatusCodes.SuccessNoContentToReturn)

            try await traktManager.checkin()
                .deleteActiveCheckin()
                .perform()
        }
    }
}
