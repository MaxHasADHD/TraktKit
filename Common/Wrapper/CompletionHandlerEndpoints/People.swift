//
//  People.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Summary
    
    /**
     Returns a single person's details.
     
     ✨ Extended Info
     */
    @discardableResult
    public func getPersonDetails<T: CustomStringConvertible>(personID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<Person>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "people/\(id)",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else {
                completion(.error(error: nil))
                return nil
        }
        return performRequest(request: request,
                              completion: completion)
    }

    // MARK: - Movies

    /**
     Returns all movies where this person is in the `cast` or `crew`. Each `cast` object will have a `character` and a standard `movie` object.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `movie` object.
     
     ✨ Extended Info
     */
    @discardableResult
    public func getMovieCredits<T: CustomStringConvertible>(personID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<CastAndCrew<PeopleMovieCastMember, PeopleMovieCrewMember>>) -> URLSessionDataTask? {
        return getCredits(type: WatchedType.Movies, id: id, extended: extended, completion: completion)
    }

    // MARK: - Shows

    /**
     Returns all shows where this person is in the `cast` or `crew`, including the `episode_count` for which they appear. Each `cast` object will have a `characters` array and a standard `show` object. If `series_regular` is `true`, this person is a series regular and not simply a guest star.
     
     The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, `camera`, `visual effects`, `lighting`, and `editing` (if there are people for those crew positions). Each of those members will have a jobs array and a standard `show` object.
     
     ✨ Extended Info
     */
    @discardableResult
    public func getShowCredits<T: CustomStringConvertible>(personID id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<CastAndCrew<PeopleTVCastMember, PeopleTVCrewMember>>) -> URLSessionDataTask? {
        return getCredits(type: WatchedType.Shows, id: id, extended: extended, completion: completion)
    }

    // MARK: - Lists

    /**
     Returns all lists that contain this person. By default, `personal` lists are returned sorted by the most `popular`.

     📄 Pagination
     */
    @discardableResult
    public func getListsContainingPerson<T: CustomStringConvertible>(personId id: T, listType: ListType? = nil, sortBy: ListSortType? = nil, completion: @escaping ObjectCompletionHandler<[TraktList]>) -> URLSessionDataTask? {
        var path = "people/\(id)/lists"
        if let listType = listType {
            path += "/\(listType)"

            if let sortBy = sortBy {
                path += "/\(sortBy)"
            }
        }

        guard let request = try? mutableRequest(forPath: path,
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request,
                              completion: completion)
    }
    
    // MARK: - Private
    
    @discardableResult
    private func getCredits<T: CustomStringConvertible, Cast: Codable & Hashable, Crew: Codable & Hashable>(type: WatchedType, id: T, extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<CastAndCrew<Cast, Crew>>) -> URLSessionDataTask? {
        guard let request = try? mutableRequest(forPath: "people/\(id)/\(type)",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: false,
            withHTTPMethod: .GET) else {
                completion(.error(error: nil))
                return nil
        }
        
        return performRequest(request: request,
                              completion: completion)
    }
}
