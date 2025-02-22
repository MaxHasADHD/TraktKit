//
//  URL+Extensions.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/25.
//

import Foundation

extension URL {
    func queryDict() -> [String: Any] {
        var info: [String: Any] = [String: Any]()
        if let queryString = self.query{
            for parameter in queryString.components(separatedBy: "&"){
                let parts = parameter.components(separatedBy: "=")
                if parts.count > 1 {
                    let key = parts[0].removingPercentEncoding
                    let value = parts[1].removingPercentEncoding
                    if key != nil && value != nil{
                        info[key!] = value
                    }
                }
            }
        }
        return info
    }

    /// Compares components, which doesn't require query parameters to be in any particular order
    public func compareComponents(_ url: URL) -> Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }

        return components.scheme == urlComponents.scheme &&
        components.host == urlComponents.host &&
        components.path == urlComponents.path &&
        components.queryItems?.enumerated().compactMap { $0.element.name }.sorted() == urlComponents.queryItems?.enumerated().compactMap { $0.element.name }.sorted() &&
        components.queryItems?.enumerated().compactMap { $0.element.value }.sorted() == urlComponents.queryItems?.enumerated().compactMap { $0.element.value }.sorted()
    }
}
