//
//  HelperFunctions.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/14/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import XCTest
import Foundation
@testable import TraktKit

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

extension XCTestCase {
    @discardableResult
    func decode<T: Codable>(_ fileName: String, to type: T.Type = T.self) -> T? {
        let data = jsonData(named: fileName)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            debugPrintError(error)
            XCTFail("Failed to parse \(T.self)")
        }
        return nil
    }
}
