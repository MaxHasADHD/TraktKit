//
//  CastAndCrewDecodingTests.swift
//  TraktKit
//
//  Created by Claude Code on 8/7/26.
//
//  Regression coverage for the cast & crew refactor (see
//  TelevisionTime/docs/cast-crew-refactor-plan.md §12). Written against real captures because
//  Trakt's own documentation missed the fields these tests exist to catch.

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct CastAndCrewDecodingTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        // MARK: - Defect B — person→crew credits with no episode_count

        @Test func personShowCreditsDecodeDespiteCrewMissingEpisodeCount() async throws {
            // Bill Lawrence, the Ted Lasso/Scrubs showrunner. His crew credits carry no
            // `episode_count` at all — a field that used to be non-optional on `PeopleTVCrewMember`,
            // so this response threw on decode and took his cast credits down with it (defect B1).
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/people/bill-lawrence-c228076a-632c-4380-9f14-ce5537434836/shows?extended=full",
                result: .success(jsonData(named: "test_get_show_credits_showrunner"))
            )

            let credits = try await traktManager.person(id: "bill-lawrence-c228076a-632c-4380-9f14-ce5537434836")
                .showCredits()
                .extend(.Full)
                .perform()

            // The decode not throwing is the regression test; these are what "decoded" means here.
            #expect(credits.cast?.count == 5)
            #expect(credits.writers?.count == 13)
            #expect(credits.directors?.count == 3)
            #expect(credits.producers?.count == 14)
            #expect(credits.createdBy?.count == 14)

            // The absent field itself: every crew credit decodes to a nil episodeCount, not a thrown error.
            #expect(credits.writers?.allSatisfy { $0.episodeCount == nil } == true)
        }

        @Test func personWithOnlyCrewCreditsYieldsNonEmptyCredits() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/people/bill-lawrence-c228076a-632c-4380-9f14-ce5537434836/shows?extended=full",
                result: .success(jsonData(named: "test_get_show_credits_showrunner"))
            )

            let credits = try await traktManager.person(id: "bill-lawrence-c228076a-632c-4380-9f14-ce5537434836")
                .showCredits()
                .extend(.Full)
                .perform()

            // Before the fix, one missing episode_count on any single crew entry threw away every
            // department's credits, not just crew's. Summing across departments — none of which
            // carry episode_count on this endpoint — is the property that failed hardest.
            let totalCrewCredits = credits.crewByDepartment.values.reduce(0) { $0 + $1.count }
            #expect(totalCrewCredits == 44)
        }

        @Test func createdByCreditsSurviveDecodingFromPersonShows() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/people/bill-lawrence-c228076a-632c-4380-9f14-ce5537434836/shows?extended=full",
                result: .success(jsonData(named: "test_get_show_credits_showrunner"))
            )

            let credits = try await traktManager.person(id: "bill-lawrence-c228076a-632c-4380-9f14-ce5537434836")
                .showCredits()
                .extend(.Full)
                .perform()

            let createdByTitles = credits.createdBy?.map(\.show.title)
            #expect(createdByTitles?.count == 14)
            #expect(createdByTitles?.contains("Ted Lasso") == true)
            #expect(createdByTitles?.contains("Scrubs") == true)
        }

        // MARK: - Defect D — 'created by' on the show endpoint

        @Test func createdByDepartmentDecodesFromShowPeople() async throws {
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/shows/ted-lasso/people?extended=full",
                result: .success(jsonData(named: "ShowCastAndCrew_CreatedBy"))
            )

            let credits = try await traktManager.show(id: "ted-lasso")
                .people()
                .extend(.Full)
                .perform()

            let creators = Set(credits.createdBy?.map(\.person.name) ?? [])
            #expect(creators == ["Jason Sudeikis", "Joe Kelly", "Bill Lawrence", "Brendan Hunt"])
        }

        // MARK: - Unknown departments survive

        @Test func unknownCrewDepartmentSurvivesDecoding() throws {
            // A department Trakt has never sent in any capture. `crewByDepartment` is keyed
            // dynamically, so this must decode into the dictionary rather than vanish — the property
            // that would have caught 'created by' before Trakt's docs did (§3.6 rule 4).
            let payload = """
            {
                "cast": [],
                "crew": {
                    "gaffer's assistant": [
                        {
                            "job": "Gaffer's Assistant",
                            "jobs": ["Gaffer's Assistant"],
                            "person": {
                                "name": "Test Person",
                                "ids": { "trakt": 1, "slug": "test-person" }
                            }
                        }
                    ]
                }
            }
            """.data(using: .utf8)!

            let credits = try JSONDecoder().decode(CastAndCrew<TVCastMember, TVCrewMember>.self, from: payload)

            let unknownDepartment = try #require(credits.crewByDepartment["gaffer's assistant"])
            #expect(unknownDepartment.count == 1)
            #expect(unknownDepartment.first?.person.name == "Test Person")
        }

        // MARK: - Headshot URLs are loadable

        @Test func headshotURLsHaveAnHTTPSScheme() async throws {
            // Ted Lasso S2E4. Chosen because it carries guest stars *and* images together — the
            // min-level ShowCastAndCrew_GuestStars fixture has neither the images nor the singular
            // character/job fields, so it cannot serve this assertion.
            try await suite.mock(
                .GET,
                "https://api.trakt.tv/shows/ted-lasso/seasons/2/episodes/4/people?extended=full,guest_stars",
                result: .success(jsonData(named: "EpisodeCastAndCrew_GuestStars"))
            )

            let credits = try await traktManager.show(id: "ted-lasso")
                .season(2).episode(4)
                .people()
                .extend(.Full, .guestStars)
                .perform()

            let castHeadshot = try #require(credits.cast?.first?.person.images?.headshot.first)
            #expect(castHeadshot.scheme == "https")

            // The credit-level image (the person in character), not just the person's generic photo.
            let creditHeadshot = try #require(credits.guestStars?.first?.images?.headshot.first)
            #expect(creditHeadshot.scheme == "https")
        }

        // MARK: - Key canaries (§3.6 rule 3)
        //
        // One test per new fixture, asserting the observed key union of its credit/person/show nodes.
        // A field Trakt adds tomorrow fails one of these BY NAME instead of silently decoding to nil
        // — this is what caught `created by` and `order` in the first place.

        @Test func showCastAndCrewCreatedByKeysAreFullyModelled() throws {
            let fixture = try jsonObject(named: "ShowCastAndCrew_CreatedBy")

            #expect(keyUnion(fixture, key: "cast") == ["character", "characters", "episode_count", "images", "order", "person"])
            #expect(keyUnion(allCrewEntries(fixture)) == ["job", "jobs", "episode_count", "images", "person"])
            #expect(keyUnion(nestedNodes(fixture, key: "cast", nestedKey: "person")) == [
                "biography", "birthday", "birthplace", "death", "gender", "height", "homepage",
                "ids", "images", "known_for_department", "name", "social_ids", "updated_at"
            ])
        }

        @Test func personShowCreditsShowrunnerKeysAreFullyModelled() throws {
            let fixture = try jsonObject(named: "test_get_show_credits_showrunner")

            #expect(keyUnion(fixture, key: "cast") == ["character", "characters", "episode_count", "series_regular", "show"])
            // No "episode_count" here — this is defect B1's absent field, named explicitly so a
            // future Trakt response that starts sending it again is also visible as a diff.
            #expect(keyUnion(allCrewEntries(fixture)) == ["job", "jobs", "show"])

            let showKeys = keyUnion(nestedNodes(fixture, key: "cast", nestedKey: "show"))
                .union(keyUnion(nestedNodes(in: allCrewEntries(fixture), nestedKey: "show")))
            #expect(showKeys == [
                "aired_episodes", "airs", "available_translations", "certification", "colors",
                "comment_count", "country", "first_aired", "genres", "homepage", "ids", "images",
                "language", "languages", "network", "original_title", "overview", "rating",
                "runtime", "social_ids", "status", "subgenres", "tagline", "title", "total_runtime",
                "trailer", "updated_at", "votes", "year"
            ])
        }

        @Test func episodeCastAndCrewGuestStarsKeysAreFullyModelled() throws {
            let fixture = try jsonObject(named: "EpisodeCastAndCrew_GuestStars")

            let expectedCreditKeys: Set<String> = ["character", "characters", "episode_count", "images", "order", "person"]
            #expect(keyUnion(fixture, key: "cast") == expectedCreditKeys)
            #expect(keyUnion(fixture, key: "guest_stars") == expectedCreditKeys)
            #expect(keyUnion(allCrewEntries(fixture)) == ["job", "jobs", "episode_count", "images", "person"])
        }

        @Test func personFullAllFieldsKeysAreFullyModelled() throws {
            let fixture = try jsonObject(named: "Person_Full_AllFields")

            #expect(Set(fixture.keys) == [
                "biography", "birthday", "birthplace", "death", "gender", "height", "homepage",
                "ids", "images", "known_for_department", "name", "social_ids", "updated_at"
            ])
        }

        // MARK: - Person_Full_AllFields — every new field, and social handles stay bare

        @Test func personFullAllFieldsDecodesWithAllNewFieldsPopulated() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/people/bryan-cranston?extended=full", result: .success(jsonData(named: "Person_Full_AllFields")))

            let person = try await traktManager.person(id: "bryan-cranston")
                .details()
                .extend(.Full)
                .perform()

            #expect(person.gender == "male")
            #expect(person.knownForDepartment == "acting")
            #expect(person.updatedAt != nil)
            #expect(person.images?.headshot.first != nil)
            #expect(person.height == 179.07000732421875)

            let socials = try #require(person.socialIds)
            // Bare handles, not URLs — the links menu builds the URL, Trakt does not send one.
            #expect(socials.twitter == "BryanCranston")
            #expect(socials.facebook == "thebryancranston")
            #expect(socials.instagram == "bryancranston")
            // A wiki page title, not a URL either.
            #expect(socials.wikipedia == "Bryan_Cranston")
        }
    }
}

// MARK: - Key-canary helpers

/// Loads a fixture as a raw JSON object, for asserting on its keys rather than decoding it into a model.
private func jsonObject(named: String) throws -> [String: Any] {
    let data = jsonData(named: named)
    let object = try JSONSerialization.jsonObject(with: data)
    return try #require(object as? [String: Any])
}

/// The union of keys across every dictionary in a JSON array, e.g. every element of a `cast` array.
private func keyUnion(_ array: [[String: Any]]) -> Set<String> {
    array.reduce(into: Set<String>()) { $0.formUnion($1.keys) }
}

/// The union of keys across the array at `key` on a fixture, e.g. `keyUnion(fixture, key: "cast")`.
private func keyUnion(_ fixture: [String: Any], key: String) -> Set<String> {
    keyUnion((fixture[key] as? [[String: Any]]) ?? [])
}

/// Every crew entry across every department in a `crew` dictionary — the shape doesn't vary by
/// department, only which people are in each bucket, so flattening them is safe.
private func allCrewEntries(_ fixture: [String: Any]) -> [[String: Any]] {
    guard let crew = fixture["crew"] as? [String: [[String: Any]]] else { return [] }
    return crew.values.flatMap { $0 }
}

/// Every nested object at `nestedKey` (e.g. `"person"`, `"show"`) across the array at `key`.
private func nestedNodes(_ fixture: [String: Any], key: String, nestedKey: String) -> [[String: Any]] {
    nestedNodes(in: (fixture[key] as? [[String: Any]]) ?? [], nestedKey: nestedKey)
}

/// Every nested object at `nestedKey` across an already-flattened array of entries.
private func nestedNodes(in entries: [[String: Any]], nestedKey: String) -> [[String: Any]] {
    entries.compactMap { $0[nestedKey] as? [String: Any] }
}
