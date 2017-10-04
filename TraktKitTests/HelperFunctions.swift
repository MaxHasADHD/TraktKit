//
//  HelperFunctions.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/14/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

func debugPrintError(_ error: Error) {
    switch error {
    case DecodingError.keyNotFound(let key, _):
        print("Key not found: \(key)")
    case DecodingError.typeMismatch(let type, let context):
        print("Type mismatch: \(type), \(context)")
    case DecodingError.valueNotFound(let value, _):
        print("Value not found: \(value)")
    case DecodingError.dataCorrupted(let context):
        print("Data corrupted: \(context)")
    default:
        break
    }
}

func jsonData(named: String) -> Data {
    let bundle = Bundle(for: MovieTests.self)
    let path = bundle.path(forResource: named, ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
    return data
}
