//
//  ScrobbleTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 3/29/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Scrobble Tests")
    struct ScrobbleTests {
        let traktManager: TraktManager

        init() async throws {
            self.traktManager = await authenticatedTraktManager()
        }

        // MARK: - Start

        @Test func startWatchingInMediaCenter() async throws {
            try mock(.POST, "https://api.trakt.tv/scrobble/start", result: .success(jsonData(named: "test_start_watching_in_media_center")))

            let scrobble = TraktScrobble(movie: SyncId(trakt: 12345), progress: 1.25)
            let response = try await traktManager.scrobble()
                .start(scrobble)
                .perform()

            #expect(response.action == "start")
            #expect(response.progress == 1.25)
            #expect(response.movie != nil)
        }

        // MARK: - Pause

        @Test func pauseWatchingInMediaCenter() async throws {
            try mock(.POST, "https://api.trakt.tv/scrobble/pause", result: .success(jsonData(named: "test_pause_watching_in_media_center")))

            let scrobble = TraktScrobble(movie: SyncId(trakt: 12345), progress: 75)
            let response = try await traktManager.scrobble()
                .pause(scrobble)
                .perform()

            #expect(response.action == "pause")
            #expect(response.progress == 75)
            #expect(response.movie != nil)
        }

        // MARK: - Stop

        @Test func stopWatchingInMediaCenter() async throws {
            try mock(.POST, "https://api.trakt.tv/scrobble/stop", result: .success(jsonData(named: "test_stop_watching_in_media_center")))

            let scrobble = TraktScrobble(movie: SyncId(trakt: 12345), progress: 99.9)
            let response = try await traktManager.scrobble()
                .stop(scrobble)
                .perform()

            #expect(response.action == "scrobble")
            #expect(response.progress == 99.9)
            #expect(response.movie != nil)
        }
    }
}
