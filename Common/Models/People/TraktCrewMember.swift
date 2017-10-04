//
//  TraktCrewMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CrewMember: Codable {
    public let job: String
    public let person: Person?
    public let movie: TraktMovie?
    public let show: TraktShow?
}
