//
//  Models.swift
//  TraktKitExample
//
//  Created by Maximilian Litteral on 2/22/26.
//

import Foundation
import TraktKit

// MARK: - Media Item

struct MediaItem: Hashable {
    let id: UUID
    let title: String
    let type: MediaType
    let imageURL: URL?
    
    init(id: UUID = UUID(), title: String, type: MediaType, imageURL: URL? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.imageURL = imageURL
    }
}

enum MediaType: String {
    case movie = "Movie"
    case show = "Show"
    case episode = "Episode"
}

// MARK: - Note

struct Note: Hashable {
    let id: UUID
    let content: String
    let mediaItem: MediaItem
    let createdAt: Date
    
    init(id: UUID = UUID(), content: String, mediaItem: MediaItem, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.mediaItem = mediaItem
        self.createdAt = createdAt
    }
}

// MARK: - Mock Data

extension MediaItem {
    static let mockData: [MediaItem] = [
        MediaItem(title: "Breaking Bad", type: .show),
        MediaItem(title: "The Shawshank Redemption", type: .movie),
        MediaItem(title: "Game of Thrones", type: .show),
        MediaItem(title: "The Dark Knight", type: .movie),
        MediaItem(title: "Stranger Things", type: .show),
        MediaItem(title: "Inception", type: .movie),
        MediaItem(title: "The Office", type: .show),
        MediaItem(title: "Pulp Fiction", type: .movie),
        MediaItem(title: "The Crown", type: .show),
    ]
}

extension Note {
    static let mockData: [Note] = [
        Note(content: "Great show with amazing character development", mediaItem: MediaItem.mockData[0]),
        Note(content: "One of the best movies I've ever seen", mediaItem: MediaItem.mockData[1]),
        Note(content: "The ending was controversial but memorable", mediaItem: MediaItem.mockData[2]),
        Note(content: "Perfect blend of action and storytelling", mediaItem: MediaItem.mockData[3]),
        Note(content: "Binged the entire season in one weekend", mediaItem: MediaItem.mockData[4]),
    ]
}

// MARK: - TraktKit Conversions

extension MediaItem {
    /// Create MediaItem from TraktMovie
    init(from movie: TraktMovie) {
        self.init(
            title: movie.title,
            type: .movie,
            imageURL: Self.fixImageURL(movie.images?.poster.first)
        )
    }
    
    /// Create MediaItem from TraktShow
    init(from show: TraktShow) {
        self.init(
            title: show.title,
            type: .show,
            imageURL: Self.fixImageURL(show.images?.poster.first)
        )
    }
    
    /// Fix Trakt image URLs that are missing the scheme
    private static func fixImageURL(_ url: URL?) -> URL? {
        guard let url = url else { return nil }
        
        // Check if URL already has a scheme
        if url.scheme != nil {
            return url
        }
        
        // Trakt returns URLs without the scheme, so we need to add https://
        let urlString = url.absoluteString
        guard let fixedURL = URL(string: "https://" + urlString) else {
            return url
        }
        
        return fixedURL
    }
}
