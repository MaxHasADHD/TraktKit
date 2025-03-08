//
//  Languages.swift
//  TraktKit
//
//  Created by Leonardo Savio Terrazzino on 20/04/2020.
//  Copyright © 2020 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Get a list of all genres, including names and slugs.
     */
    @discardableResult
    public func listLanguages(type: WatchedType, completion: @escaping ObjectCompletionHandler<[Languages]>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "languages/\(type)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else {
                                                completion(.error(error: nil))
                                                return nil
                                           }
        return performRequest(request: request,
                              completion: completion)
    }
}

