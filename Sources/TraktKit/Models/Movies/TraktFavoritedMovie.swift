//
//  TraktFavoritedMovie.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

public struct TraktFavoritedMovie: TraktObject {
    public let userCount: Int
    public let movie: TraktMovie

    enum CodingKeys: String, CodingKey {
        case userCount = "user_count"
        case movie
    }
}
