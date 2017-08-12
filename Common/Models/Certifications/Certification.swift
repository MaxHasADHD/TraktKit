//
//  Certification.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 8/10/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Certifications: Codable {
    let us: [Certification]
    
    enum CodingKeys: String, CodingKey {
        case us
    }
    
    struct Certification: Codable {
        let name: String
        let slug: String
        let description: String
    }
}
