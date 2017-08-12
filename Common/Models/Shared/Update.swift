//
//  Update.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/10/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Update: Codable {
    let updatedAt: Date
    let movie: TraktMovie?
    let show: TraktShow?
    
    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case movie
        case show
    }
}
