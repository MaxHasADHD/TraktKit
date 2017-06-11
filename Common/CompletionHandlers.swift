//
//  CompletionHandlers.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/29/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    // MARK: - Result Types
    public enum DictionaryResultType {
        case success(dict: RawJSON)
        case error(error: NSError?)
    }
    
    public enum SuccessResultType {
        case success
        case fail
    }
    
    public enum ArrayResultType {
        case success(array: [RawJSON])
        case error(error: NSError?)
    }
    
    public enum CommentsResultType {
        case success(comments: [Comment])
        case error(error: NSError?)
    }
    
    public enum CastCrewResultType {
        case success(cast: [CastMember], crew: [CrewMember])
        case error(error: NSError?)
    }
    
    public enum WatchingResultType {
        case checkedIn(watching: TraktWatching)
        case notCheckedIn
        case error(error: NSError?)
    }
    
    public enum HiddenItemsResultType {
        case success(items: [HiddenItem])
        case error(error: Error?)
    }
    
    public enum CheckinResultType {
        case success(checkin: TraktCheckin)
        case checkedIn(expiration: Date)
        case error(error: Error?)
    }
    
    // MARK: - Completion handlers
    
    // MARK: Common
    public typealias ResultCompletionHandler = (_ result: DictionaryResultType) -> Void
    public typealias SuccessCompletionHandler = (_ result: SuccessResultType) -> Void
    public typealias ArrayCompletionHandler = (_ result: ArrayResultType) -> Void
    public typealias CommentsCompletionHandler = (_ result: CommentsResultType) -> Void
    public typealias CastCrewCompletionHandler = (_ result: CastCrewResultType) -> Void
    
    public typealias watchingCompletionHandler = (_ result: WatchingResultType) -> Void

    public typealias SearchCompletionHandler = (_ result: ObjectsResultType<TraktSearchResult>) -> Void
    public typealias statsCompletionHandler = (_ result: ObjectResultType<TraktStats>) -> Void
    
    // MARK: Calendar
    public typealias dvdReleaseCompletionHandler = (_ result: ObjectsResultType<TraktDVDReleaseMovie>) -> Void
    
    // MARK: Checkin
    public typealias checkinCompletionHandler = (_ result: CheckinResultType) -> Void
    
    // MARK: Shows
    public typealias ShowCompletionHandler = (_ result: ObjectResultType<TraktShow>) -> Void
    public typealias ShowsCompletionHandler = (_ result: ObjectsResultType<TraktShow>) -> Void
    public typealias TrendingShowsCompletionHandler = (_ result: ObjectsResultType<TraktTrendingShow>) -> Void
    public typealias MostShowsCompletionHandler = (_ result: ObjectsResultType<TraktMostShow>) -> Void
    public typealias AnticipatedShowCompletionHandler = (_ result: ObjectsResultType<TraktAnticipatedShow>) -> Void
    public typealias ShowTranslationsCompletionHandler = (_ result: ObjectsResultType<TraktShowTranslation>) -> Void
    public typealias SeasonsCompletionHandler = (_ result: ObjectsResultType<TraktSeason>) -> Void
    
    public typealias WatchedShowsCompletionHandler = (_ result: ObjectsResultType<TraktWatchedShow>) -> Void
    public typealias ShowWatchedProgressCompletionHandler = (_ result: ObjectResultType<TraktShowWatchedProgress>) -> Void
    
    // MARK: Episodes
    public typealias EpisodeCompletionHandler = (_ result: ObjectsResultType<TraktEpisode>) -> Void
    public typealias EpisodesCompletionHandler = (_ result: ObjectsResultType<TraktEpisode>) -> Void
    
    // MARK: Movies
    public typealias MovieCompletionHandler = (_ result: ObjectResultType<TraktMovie>) -> Void
    public typealias MoviesCompletionHandler = (_ result: ObjectsResultType<TraktMovie>) -> Void
    public typealias TrendingMoviesCompletionHandler = (_ result: ObjectsResultType<TraktTrendingMovie>) -> Void
    public typealias MostMoviesCompletionHandler = (_ result: ObjectsResultType<TraktMostShow>) -> Void
    public typealias AnticipatedMovieCompletionHandler = (_ result: ObjectsResultType<TraktAnticipatedMovie>) -> Void
    public typealias MovieTranslationsCompletionHandler = (_ result: ObjectsResultType<TraktMovieTranslation>) -> Void
    public typealias WatchedMoviesCompletionHandler = (_ result: ObjectsResultType<TraktWatchedMovie>) -> Void
    public typealias BoxOfficeMoviesCompletionHandler = (_ result: ObjectsResultType<TraktBoxOfficeMovie>) -> Void
    
    // MARK: Sync
    public typealias LastActivitiesCompletionHandler = (_ result: ObjectResultType<TraktLastActivities>) -> Void
    public typealias RatingsCompletionHandler = (_ result: ObjectsResultType<TraktRating>) -> Void
    public typealias HistoryCompletionHandler = (_ result: ObjectsResultTypePagination<TraktHistoryItem>) -> Void
    public typealias CollectionCompletionHandler = (_ result: ObjectsResultType<TraktCollectedItem>) -> Void
    
    // MARK: Users
    public typealias ListCompletionHandler = (_ result: ObjectResultType<TraktList>) -> Void
    public typealias ListsCompletionHandler = (_ result: ObjectsResultType<TraktList>) -> Void
    public typealias ListItemCompletionHandler = (_ result: ObjectsResultType<TraktListItem>) -> Void
    public typealias HiddenItemsCompletionHandler = (_ result: HiddenItemsResultType) -> Void
    
    // MARK: - Perform Requests
    
    /// Dictionary
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping ResultCompletionHandler) -> URLSessionDataTask? {
        
        let datatask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else { return completion(.error(error: error as NSError?)) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: nil))
                    }
                    return
            }
            
            // Check data
            guard let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    completion(.success(dict: dict))
                }
            } catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Array
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping ArrayCompletionHandler) -> URLSessionDataTask? {
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else { return completion(.error(error: error as NSError?)) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: nil))
                    }
                    
                    return
            }
            
            // Check data
            guard let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [RawJSON] {
                    completion(.success(array: array))
                }
            } catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Success / Failure
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTask? {
        let datatask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { return completion(.fail) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code
                else {
                    return completion(.fail)
            }
            
            // Check data
            guard data != nil else { return completion(.fail) }
            
            completion(.success)
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Comments
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ArrayCompletionHandler = { (result: ArrayResultType) -> Void in
            
            switch result {
            case .success(let array):
                let comments: [Comment] = initEach(array)
                completion(.success(comments: comments))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Cast and crew
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ResultCompletionHandler = { (result: DictionaryResultType) -> Void in
            switch result {
            case .success(let dict):
                var crew: [CrewMember] = []
                var cast: [CastMember] = []
                
                // Crew
                if let jsonCrew = dict["crew"] as? RawJSON {
                    func addMembers(_ members: [RawJSON]) {
                        crew += initEach(members)
                    }
                    
                    if let members = jsonCrew["directing"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["writing"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["production"] as? [RawJSON] { addMembers(members) }
                    if let members = jsonCrew["crew"] as? [RawJSON] { addMembers(members) }
//                    if let members = jsonCrew["camera"] as? [RawJSON] { addMembers(members) }
//                    if let members = jsonCrew["sound"] as? [RawJSON] { addMembers(members) }
                }
                
                // Cast
                if let members = dict["cast"] as? [[String: AnyObject]] {
                    cast += initEach(members)
                }
                
                completion(.success(cast: cast, crew: crew))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Hidden Items
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping HiddenItemsCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ArrayCompletionHandler = { (result: ArrayResultType) -> Void in
            
            switch result {
            case .success(let array):
                let items: [HiddenItem] = initEach(array)
                completion(.success(items: items))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Checkin
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping checkinCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ResultCompletionHandler = { (result: DictionaryResultType) -> Void in
            switch result {
            case .success(let dict):
                if let checkin = TraktCheckin(json: dict) {
                    completion(.success(checkin: checkin))
                } else if let expirationDate = Date.dateFromString(dict["expires_at"]) {
                    completion(.checkedIn(expiration: expirationDate))
                } else {
                    completion(.error(error: nil))
                }
                
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    // Generic array of Trakt objects
    func performRequest<T: TraktProtocol>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectResultType<T>) -> Void)) -> URLSessionDataTask? {
        
        let aCompletion: ResultCompletionHandler = { (result) -> Void in
            switch result {
            case .success(let dict):
                guard let traktObject = T(json: dict) else { return completion(.error(error: nil)) }
                completion(.success(object: traktObject))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        
        return dataTask
    }
    
    /// Array of TraktProtocol objects
    func performRequest<T: TraktProtocol>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else { return completion(.error(error: error as NSError?)) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: nil))
                    }
                    
                    return
            }
            
            // Check data
            guard let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [RawJSON] {
                    let objects: [T] = initEach(array)
                    completion(.success(objects: objects))
                } else {
                    completion(.error(error: nil))
                }
            } catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Array of ObjectsResultTypePagination objects
    func performRequest<T: TraktProtocol>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTask? {
        
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else { return completion(.error(error: error as NSError?)) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == code
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: nil))
                    }
                    
                    return
            }
            
            var pageCount: Int = 0
            if let pCount = HTTPResponse.allHeaderFields["x-pagination-page-count"] as? String,
                let pCountInt = Int(pCount) {
                pageCount = pCountInt
            }
            
            var currentPage: Int = 0
            if let cPage = HTTPResponse.allHeaderFields["x-pagination-page"] as? String,
                let cPageInt = Int(cPage) {
                currentPage = cPageInt
            }
            
            // Check data
            guard
                let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [RawJSON] {
                    let objects: [T] = initEach(array)
                    completion(.success(objects: objects, currentPage: currentPage, limit: pageCount))
                } else {
                    completion(.error(error: nil))
                }
            } catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
}
