//
//  NotesTests.swift
//  TraktKit
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite
    struct NotesTests {
        let suite: TraktTestSuite
        let traktManager: TraktManager

        init() async throws {
            self.suite = await TraktTestSuite()
            self.traktManager = await suite.traktManager()
        }

        // MARK: - Add

        @Test func addNoteForMovie() async throws {
            try await suite.mock(.POST, "https://api.trakt.tv/notes", result: .success(jsonData(named: "test_get_note")))

            let body = TraktNoteBody(
                movie: SyncId(trakt: 28),
                notes: "This is a great movie!"
            )
            let note = try await traktManager.notes
                .add(body)
                .perform()

            #expect(note.id == 1)
            #expect(note.notes == "This is a great movie!")
            #expect(note.privacy == "public")
            #expect(note.spoiler == false)
            #expect(note.user.username == "sean")
        }

        // MARK: - Get

        @Test func getNote() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/notes/1", result: .success(jsonData(named: "test_get_note")))

            let note = try await traktManager.note(id: 1)
                .get()
                .perform()

            #expect(note.id == 1)
            #expect(note.notes == "This is a great movie!")
            #expect(note.privacy == "public")
            #expect(note.spoiler == false)
            #expect(note.user.username == "sean")
        }

        // MARK: - Update

        @Test func updateNote() async throws {
            try await suite.mock(.PUT, "https://api.trakt.tv/notes/1", result: .success(jsonData(named: "test_get_note")))

            let body = TraktNoteBody(notes: "This is a great movie!")
            let note = try await traktManager.note(id: 1)
                .update(body)
                .perform()

            #expect(note.id == 1)
            #expect(note.notes == "This is a great movie!")
        }

        // MARK: - Delete

        @Test func deleteNote() async throws {
            try await suite.mock(.DELETE, "https://api.trakt.tv/notes/1", result: .success(.init()))

            try await traktManager.note(id: 1)
                .delete()
                .perform()
        }

        // MARK: - Item

        @Test func getNoteItem() async throws {
            try await suite.mock(.GET, "https://api.trakt.tv/notes/1/item", result: .success(jsonData(named: "test_get_note_item")))

            let item = try await traktManager.note(id: 1)
                .item()
                .perform()

            #expect(item.type == "movie")
            let movie = try #require(item.movie)
            #expect(movie.title == "Guardians of the Galaxy")
            #expect(movie.year == 2014)
        }

        @Test func decodeNoteAttachedItemWithoutNote() throws {
            // Verify that TraktNoteAttachedItem decodes correctly without a 'note' property
            let json: [String: Any] = [
                "type": "movie",
                "movie": [
                    "title": "Guardians of the Galaxy",
                    "year": 2014,
                    "ids": [
                        "trakt": 28,
                        "slug": "guardians-of-the-galaxy-2014",
                        "imdb": "tt2015381",
                        "tmdb": 118340
                    ]
                ]
            ]
            let data = try JSONSerialization.data(withJSONObject: json)

            let item = try JSONDecoder().decode(TraktNoteAttachedItem.self, from: data)
            #expect(item.type == "movie")
            let movie = try #require(item.movie)
            #expect(movie.title == "Guardians of the Galaxy")
            #expect(movie.year == 2014)
            #expect(item.show == nil)
            #expect(item.episode == nil)
        }
    }
}
