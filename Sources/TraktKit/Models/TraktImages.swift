//
//  TraktImages.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 9/16/25.
//

import Foundation

public struct TraktImages: TraktObject {
    // Movies / Series / Season
    public let fanart: [URL]
    public let poster: [URL]
    public let logo: [URL]
    public let clearart: [URL]
    public let banner: [URL]
    public let thumb: [URL]

    // Episodes
    public let screenshot: [URL]

    // Cast / Crew
    public let headshot: [URL]

    public init(from decoder: any Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        self.fanart     = Self.urls(try? container.decodeIfPresent([String].self, forKey: .fanart))
        self.poster     = Self.urls(try? container.decodeIfPresent([String].self, forKey: .poster))
        self.logo       = Self.urls(try? container.decodeIfPresent([String].self, forKey: .logo))
        self.clearart   = Self.urls(try? container.decodeIfPresent([String].self, forKey: .clearart))
        self.banner     = Self.urls(try? container.decodeIfPresent([String].self, forKey: .banner))
        self.thumb      = Self.urls(try? container.decodeIfPresent([String].self, forKey: .thumb))
        self.screenshot = Self.urls(try? container.decodeIfPresent([String].self, forKey: .screenshot))
        self.headshot   = Self.urls(try? container.decodeIfPresent([String].self, forKey: .headshot))
    }

    /// Trakt returns scheme-less paths (`media.trakt.tv/images/…`). Those parse into a `URL`
    /// perfectly happily, but as a relative reference with a nil scheme, which no image loader can
    /// fetch — so the scheme goes on here rather than at every call site that would otherwise have
    /// to know.
    private static func urls(_ paths: [String]??) -> [URL] {
        (paths.flatMap { $0 } ?? []).compactMap { path in
            if path.contains("://") {
                URL(string: path)
            } else if path.hasPrefix("//") {
                URL(string: "https:" + path)
            } else {
                URL(string: "https://" + path)
            }
        }
    }
}
