//
//  Certification.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 8/10/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Certifications: Codable, Hashable {
    public let us: [Certification]
    
    enum CodingKeys: String, CodingKey {
        case us
    }
    
    public struct Certification: Codable, Hashable {
        public let name: String
        public let slug: String
        public let description: String
    }
}
