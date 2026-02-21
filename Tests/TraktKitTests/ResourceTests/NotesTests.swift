//
//  NotesTests.swift
//  TraktKit
//

import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct NotesTests {

        // MARK: - Add

        @Test func addNoteForMovie() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.POST, "https://api.trakt.tv/notes", result: .success(jsonData(named: "test_get_note")))

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
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/notes/1", result: .success(jsonData(named: "test_get_note")))

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
            let traktManager = await authenticatedTraktManager()
            try mock(.PUT, "https://api.trakt.tv/notes/1", result: .success(jsonData(named: "test_get_note")))

            let body = TraktNoteBody(notes: "This is a great movie!")
            let note = try await traktManager.note(id: 1)
                .update(body)
                .perform()

            #expect(note.id == 1)
            #expect(note.notes == "This is a great movie!")
        }

        // MARK: - Delete

        @Test func deleteNote() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.DELETE, "https://api.trakt.tv/notes/1", result: .success(.init()))

            try await traktManager.note(id: 1)
                .delete()
                .perform()
        }

        // MARK: - Item

        @Test func getNoteItem() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/notes/1/item", result: .success(jsonData(named: "test_get_note_item")))

            let item = try await traktManager.note(id: 1)
                .item()
                .perform()

            #expect(item.type == "movie")
            let movie = try #require(item.movie)
            #expect(movie.title == "Guardians of the Galaxy")
            #expect(movie.year == 2014)
        }
    }
}
