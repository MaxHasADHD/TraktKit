//
//  TraktUser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct User: TraktProtocol {
    public let username: String
    public let isPrivate: Bool
    public let name: String
    public let isVIP: Bool
    public let isVIPEP: Bool
    
    // Initialize
    public init?(json: RawJSON?) {
        guard
            let json = json,
            let isPrivate = json["private"] as? Bool,
            let isVIP = json["vip"] as? Bool,
            let isVIPEP = json["vip_ep"] as? Bool else { return nil }
        
        self.username = json["username"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        self.isPrivate = isPrivate
        self.name = json["name"] as? String ?? NSLocalizedString("COMMENTS_ANONYMOUS_NAME", comment: "Anonymous")
        self.isVIP = isVIP
        self.isVIPEP = isVIPEP
    }
}
