//
//  TraktFavoritedShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

public struct TraktFavoritedShow: TraktObject {
    public let userCount: Int
    public let show: TraktShow

    enum CodingKeys: String, CodingKey {
        case userCount = "user_count"
        case show
    }
}
