//
//  TraktStudio.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

import Foundation

public struct TraktStudio: TraktObject {
    public let name: String
    public let country: String
    public let ids: IDS

    public struct IDS: TraktObject {
        public let trakt: Int
        public let slug: String
        public let tmdb: Int
    }
}
