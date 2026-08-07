//  Person.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

// Actor/Actress/Crew member
public struct Person: TraktObject {
    /// Bare handles, not URLs — `wikipedia` is a page title (`"Bryan_Cranston"`). Callers build the
    /// links, and should tolerate Trakt one day sending a full URL instead.
    public struct SocialIDs: TraktObject {
        public let twitter: String?
        public let facebook: String?
        public let instagram: String?
        public let wikipedia: String?
    }

    // Extended: Min
    public let name: String
    public let ids: ID

    // Extended: Full
    public let biography: String?
    public let birthday: Date?
    public let death: Date?
    public let birthplace: String?
    public let homepage: URL?
    public let socialIds: SocialIDs?
    public let gender: String?
    /// Lowercase, sharing the department vocabulary used by the crew object — e.g. `"acting"`.
    public let knownForDepartment: String?
    public let updatedAt: Date?
    public let images: TraktImages?
    /// Centimetres, and fractional in practice (181.61) — not an `Int`.
    public let height: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case ids

        case biography
        case birthday
        case death
        case birthplace
        case homepage
        case socialIds = "social_ids"
        case gender
        case knownForDepartment = "known_for_department"
        case updatedAt = "updated_at"
        case images
        case height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: CodingKeys.name)
        ids = try container.decode(ID.self, forKey: CodingKeys.ids)
        biography = try container.decodeIfPresent(String.self, forKey: CodingKeys.biography)
        birthday = try container.decodeIfPresent(Date.self, forKey: CodingKeys.birthday)
        death = try container.decodeIfPresent(Date.self, forKey: CodingKeys.death)
        birthplace = try container.decodeIfPresent(String.self, forKey: CodingKeys.birthplace)
        do {
            homepage = try container.decodeIfPresent(URL.self, forKey: CodingKeys.homepage)
        } catch {
            homepage = nil
        }
        // Everything below is absent at extended=min, so none of it may be required.
        socialIds = try? container.decodeIfPresent(SocialIDs.self, forKey: CodingKeys.socialIds)
        gender = try container.decodeIfPresent(String.self, forKey: CodingKeys.gender)
        knownForDepartment = try container.decodeIfPresent(String.self, forKey: CodingKeys.knownForDepartment)
        updatedAt = try? container.decodeIfPresent(Date.self, forKey: CodingKeys.updatedAt)
        images = try? container.decodeIfPresent(TraktImages.self, forKey: CodingKeys.images)
        height = try container.decodeIfPresent(Double.self, forKey: CodingKeys.height)
    }

}
