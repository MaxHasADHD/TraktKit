//
//  Certifications.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/24/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {

    /**
     Most TV shows and movies have a certification to indicate the content rating. Some API methods allow filtering by certification, so it's good to cache this list in your app.

     Note: Only `us` certifications are currently returned.
     */
    @available(*, deprecated, message: "Use certifications.list().perform() with async/await instead. See MIGRATION_GUIDE.md for examples.")
    @discardableResult
    public func getCertifications(completion: @escaping ObjectCompletionHandler<Certifications>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "certifications",
            withQuery: [:],
            isAuthorized: true,
            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
}
