//
//  MediaColors.swift
//  TraktKit
//
//  Dominant colors extracted from artwork. Available when requesting extended `colors`.
//

import Foundation

public struct MediaColors: TraktObject {
    /// Dominant colors of the poster, ordered most to least prominent (hex strings).
    public let poster: [String]?

    public init(poster: [String]? = nil) {
        self.poster = poster
    }
}
