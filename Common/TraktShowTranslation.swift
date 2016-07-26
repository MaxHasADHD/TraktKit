//
//  TraktShowTranslation.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktShowTranslation: TraktProtocol {
    public let title: String
    public let overview: String
    public let language: String
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let title = json["title"] as? String,
            let overview = json["overview"] as? String,
            let language = json["language"] as? String else { return nil }
        
        self.title       = title
        self.overview    = overview
        self.language    = language
    }
}
