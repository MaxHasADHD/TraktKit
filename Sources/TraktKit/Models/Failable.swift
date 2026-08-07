//
//  Failable.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/7/26.
//

import Foundation

/// Decodes a value, or nothing, without failing its container.
///
/// Arrays of credits are decoded through this so one malformed element costs one row instead of the
/// whole response. Trakt has changed these payloads under us before — a single missing
/// `episode_count` used to throw away a person's entire filmography — and the costs are wildly
/// asymmetric: a dropped row is a cosmetic gap, a thrown decode is an empty screen.
struct Failable<Wrapped: Decodable>: Decodable {
    let value: Wrapped?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try? container.decode(Wrapped.self)
    }
}
