//
//  AccountSettingsTests.swift
//  TraktKitTests
//
//  Trakt documents `limits` as nullable and every limit inside it as required, so
//  the members of `Limits` are non-optional. Because that schema is actively
//  changing (the published OpenAPI spec already omits keys the live API returns),
//  `AccountSettings` decodes the `limits` key leniently: a payload that breaks the
//  contract degrades to `nil` rather than failing the whole settings call.
//

import Foundation
import Testing
import SwiftAPIClient
@testable import TraktKit

@Suite("AccountSettings Decoding Tests")
struct AccountSettingsTests {

    private func decodeSettings(_ fixture: String) throws -> AccountSettings {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        return try decoder.decode(AccountSettings.self, from: jsonData(named: fixture))
    }

    @Test("Full limits payload decodes every field")
    func fullLimitsDecodes() throws {
        let settings = try decodeSettings("test_get_settings")
        let limits = try #require(settings.limits)

        #expect(settings.user.name == "Justin Nemeth")
        #expect(limits.list.count == 2)
        #expect(limits.list.itemCount == 100)
        #expect(limits.watchlist.itemCount == 100)
        #expect(limits.favorites.itemCount == 100)
        #expect(limits.search.recentCount == 5)
        #expect(limits.collection.itemCount == 100)
        #expect(limits.notes.itemCount == 100)
    }

    @Test("Settings without a limits object still decode")
    func missingLimitsDecodes() throws {
        let settings = try decodeSettings("test_get_settings_no_limits")

        #expect(settings.limits == nil)
        // The rest of the payload must survive intact.
        #expect(settings.user.username == "justin")
        #expect(settings.connections.twitter == true)
        #expect(settings.sharingText.watching == "I'm watching [item]")
    }

    @Test("An explicitly null limits object decodes as nil")
    func nullLimitsDecodes() throws {
        let settings = try decodeSettings("test_get_settings_null_limits")

        #expect(settings.limits == nil)
        #expect(settings.user.username == "justin")
    }

    @Test("Limits missing a documented-required field degrade to nil instead of failing the decode")
    func partialLimitsDegradeToNil() throws {
        // The fixture has `list` without `item_count` and no `favorites`/`search`/
        // `collection`/`notes` at all — a contract violation. The lenient path drops
        // the whole limits object rather than throwing, so the rest of the settings
        // still reach the caller.
        let settings = try decodeSettings("test_get_settings_partial_limits")

        #expect(settings.limits == nil)
        #expect(settings.user.username == "justin")
        #expect(settings.connections.twitter == true)
        #expect(settings.sharingText.watching == "I'm watching [item]")
    }

    @Test("Unknown limits keys are ignored rather than failing the decode")
    func unknownLimitKeysDecode() throws {
        let settings = try decodeSettings("test_get_settings_unknown_limits")
        let limits = try #require(settings.limits)

        #expect(limits.list.count == 100)
        #expect(limits.list.itemCount == 5000)
        #expect(limits.watchlist.itemCount == 5000)
        #expect(limits.notes.itemCount == 5000)
    }
}
