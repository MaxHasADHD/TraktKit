//
//  People.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Public
    
    /**
     Returns a single person's details.
     
     ✨ Extended Info
     */
    @discardableResult
    public func getPersonDetails<T: CustomStringConvertible>(personID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<Person>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "people/\(id)",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else {
                completion(.error(error: nil))
                return nil
        }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }
    
    /**
     Returns all movies where this person is in the `cast` or `crew`. Each `cast` object will have a `character` and a standard `movie` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `movie` object.
     
     ✨ Extended Info
     */
    @discardableResult
    public func getMovieCredits<T: CustomStringConvertible>(movieID id: T, extended: [ExtendedType] = [.Min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        return getCredits(type: WatchedType.Movies, id: id, extended: extended, completion: completion)
    }
    
    /**
     Returns all shows where this person is in the `cast` or `crew`. Each `cast` object will have a `character` and a standard `show` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `show` object.
     
     ✨ Extended Info
     */
    @discardableResult
    public func getShowCredits<T: CustomStringConvertible>(showID id: T, extended: [ExtendedType] = [.Min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        return getCredits(type: WatchedType.Shows, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Private
    
    @discardableResult
    private func getCredits<T: CustomStringConvertible>(type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "people/\(id)/\(type)",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else {
                completion(.error(error: nil))
                return nil
        }
        
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }
}
