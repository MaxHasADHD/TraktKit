
//
//  NotesResource.swift
//  TraktKit
//

import Foundation

extension TraktManager {
    /**
     Notes allow users to annotate movies, shows, seasons, episodes, and people with text.
     */
    public struct NotesResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Add a note for a movie, show, season, episode, or person.

         🔥 VIP Enhanced 🔒 OAuth Required 😁 Emojis

         - parameter body: The note body containing the media item, note text, and optional metadata.
         */
        public func add(_ body: TraktNoteBody) -> Route<TraktNote> {
            Route(paths: ["notes"], body: body, method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }
    }

    /**
     Endpoints scoped to a single note by its ID.
     */
    public struct NoteResource {
        private let id: CustomStringConvertible
        private let traktManager: TraktManager

        internal init(id: CustomStringConvertible, traktManager: TraktManager) {
            self.id = id
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Get a single note.

         🔒 OAuth Required 😁 Emojis

         - returns: The note.
         */
        public func get() -> Route<TraktNote> {
            Route(paths: ["notes", id], method: .GET, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Update a single note.

         🔒 OAuth Required 😁 Emojis

         - parameter body: The updated note body.
         - returns: The updated note.
         */
        public func update(_ body: TraktNoteBody) -> Route<TraktNote> {
            Route(paths: ["notes", id], body: body, method: .PUT, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Delete a single note.

         🔒 OAuth Required
         */
        public func delete() -> EmptyRoute {
            EmptyRoute(paths: ["notes", id], method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Get the media item attached to a note.

         ✨ Extended Info

         - returns: The item attached to the note.
         */
        public func item() -> Route<TraktNoteItem> {
            Route(paths: ["notes", id, "item"], method: .GET, requiresAuthentication: false, traktManager: traktManager)
        }
    }
}
