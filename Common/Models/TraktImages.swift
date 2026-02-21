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
        self.fanart     = (try? container.decodeIfPresent([URL].self, forKey: .fanart)) ?? []
        self.poster     = (try? container.decodeIfPresent([URL].self, forKey: .poster)) ?? []
        self.logo       = (try? container.decodeIfPresent([URL].self, forKey: .logo)) ?? []
        self.clearart   = (try? container.decodeIfPresent([URL].self, forKey: .clearart)) ?? []
        self.banner     = (try? container.decodeIfPresent([URL].self, forKey: .banner)) ?? []
        self.thumb      = (try? container.decodeIfPresent([URL].self, forKey: .thumb)) ?? []
        self.screenshot = (try? container.decodeIfPresent([URL].self, forKey: .screenshot)) ?? []
        self.headshot   = (try? container.decodeIfPresent([URL].self, forKey: .headshot)) ?? []
    }
}
