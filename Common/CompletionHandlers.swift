//
//  CompletionHandlers.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/29/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Generic result type
public enum ObjectResultType<T: Codable> {
    case success(object: T)
    case error(error: NSError?)
}

/// Generic results type
public enum ObjectsResultType<T: Codable> {
    case success(objects: [T])
    case error(error: NSError?)
}

/// Generic results type + Pagination
public enum ObjectsResultTypePagination<T: Codable> {
    case success(objects: [T], currentPage: Int, limit: Int)
    case error(error: NSError?)
}

extension TraktManager {
    
    // MARK: - Result Types
    
    public enum DataResultType {
        case success(data: Data)
        case error(error: NSError?)
    }
    
    public enum SuccessResultType {
        case success
        case fail
    }
    
    public enum ArrayResultType<T: Codable> {
        case success(array: [T])
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
    public typealias ObjectCompletionHandler<T: Codable> = (_ result: ObjectResultType<T>) -> Void
    public typealias ObjectsCompletionHandler<T: Codable> = (_ result: ObjectsResultType<T>) -> Void
    
    public typealias DataResultCompletionHandler = (_ result: DataResultType) -> Void
    public typealias SuccessCompletionHandler = (_ result: SuccessResultType) -> Void
    public typealias ArrayCompletionHandler<T: Codable> = (_ result: ArrayResultType<T>) -> Void
    public typealias CommentsCompletionHandler = (_ result: CommentsResultType) -> Void
    public typealias CastCrewCompletionHandler = (_ result: CastCrewResultType) -> Void
    
    public typealias watchingCompletionHandler = (_ result: WatchingResultType) -> Void

    public typealias SearchCompletionHandler = ObjectsCompletionHandler<TraktSearchResult>
    public typealias statsCompletionHandler = ObjectCompletionHandler<TraktStats>
    
    // MARK: Calendar
    public typealias dvdReleaseCompletionHandler = ObjectsCompletionHandler<TraktDVDReleaseMovie>
    
    // MARK: Checkin
    public typealias checkinCompletionHandler = (_ result: CheckinResultType) -> Void
    
    // MARK: Shows
    public typealias TrendingShowsCompletionHandler = ObjectsCompletionHandler<TraktTrendingShow>
    public typealias MostShowsCompletionHandler = ObjectsCompletionHandler<TraktMostShow>
    public typealias AnticipatedShowCompletionHandler = ObjectsCompletionHandler<TraktAnticipatedShow>
    public typealias ShowTranslationsCompletionHandler = ObjectsCompletionHandler<TraktShowTranslation>
    public typealias SeasonsCompletionHandler = ObjectsCompletionHandler<TraktSeason>
    
    public typealias WatchedShowsCompletionHandler = ObjectsCompletionHandler<TraktWatchedShow>
    public typealias ShowWatchedProgressCompletionHandler = ObjectCompletionHandler<TraktShowWatchedProgress>
    
    // MARK: Episodes
    public typealias EpisodeCompletionHandler = (_ result: ObjectsResultType<TraktEpisode>) -> Void
    public typealias EpisodesCompletionHandler = (_ result: ObjectsResultType<TraktEpisode>) -> Void
    
    // MARK: Movies
    public typealias MovieCompletionHandler = ObjectCompletionHandler<TraktMovie>
    public typealias MoviesCompletionHandler = ObjectsCompletionHandler<TraktMovie>
    public typealias TrendingMoviesCompletionHandler = ObjectsCompletionHandler<TraktTrendingMovie>
    public typealias MostMoviesCompletionHandler = ObjectsCompletionHandler<TraktMostShow>
    public typealias AnticipatedMovieCompletionHandler = ObjectsCompletionHandler<TraktAnticipatedMovie>
    public typealias MovieTranslationsCompletionHandler = ObjectsCompletionHandler<TraktMovieTranslation>
    public typealias WatchedMoviesCompletionHandler = ObjectsCompletionHandler<TraktWatchedMovie>
    public typealias BoxOfficeMoviesCompletionHandler = ObjectsCompletionHandler<TraktBoxOfficeMovie>
    
    // MARK: Sync
    public typealias LastActivitiesCompletionHandler = ObjectCompletionHandler<TraktLastActivities>
    public typealias RatingsCompletionHandler = ObjectsCompletionHandler<TraktRating>
    public typealias HistoryCompletionHandler = ObjectsCompletionHandler<TraktHistoryItem>
    public typealias CollectionCompletionHandler = ObjectsCompletionHandler<TraktCollectedItem>
    
    // MARK: Users
    public typealias ListCompletionHandler = ObjectCompletionHandler<TraktList>
    public typealias ListsCompletionHandler = ObjectsCompletionHandler<TraktList>
    public typealias ListItemCompletionHandler = ObjectsCompletionHandler<TraktListItem>
    public typealias HiddenItemsCompletionHandler = (_ result: HiddenItemsResultType) -> Void
    
    // MARK: - Perform Requests
    
    /// Data
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping DataResultCompletionHandler) -> URLSessionDataTask? {
        
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
            completion(.success(data: data))
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Array
    func performRequest<T>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping ArrayCompletionHandler<T>) -> URLSessionDataTask? {
        let aCompletion: DataResultCompletionHandler = { (result: DataResultType) -> Void in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
                do {
                    let array = try decoder.decode([T].self, from: data)
                    completion(.success(array: array))
                } catch let jsonSerializationError as NSError {
                    completion(.error(error: jsonSerializationError))
                }
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
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
                else { return completion(.fail) }
            
            // Check data
            guard data != nil else { return completion(.fail) }
            
            completion(.success)
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Cast and crew
    /*func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ObjectCompletionHandler<[String : Any]> = { (result: ObjectResultType) -> Void in
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
        
        return performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
    }*/
    
    /// Hidden Items
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping HiddenItemsCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: ArrayCompletionHandler<HiddenItem> = { (result: ArrayResultType) -> Void in
            
            switch result {
            case .success(let hiddenItems):
                completion(.success(items: hiddenItems))
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        return dataTask
    }
    
    /// Checkin
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping checkinCompletionHandler) -> URLSessionDataTask? {
        let aCompletion: DataResultCompletionHandler = { (result: DataResultType) -> Void in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
                
                if let checkin = try? decoder.decode(TraktCheckin.self, from: data) {
                    completion(.success(checkin: checkin))
                } else if let rawDict = try? decoder.decode([String : Any].self, from: data),
                    let expirationDate = try? Date.dateFromString(rawDict["expires_at"]) {
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
    func performRequest<T>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectResultType<T>) -> Void)) -> URLSessionDataTask? {
        
        let aCompletion: DataResultCompletionHandler = { (result) -> Void in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object: object))
                } catch {
                    completion(.error(error: nil))
                }
            case .error(let error):
                completion(.error(error: error))
            }
        }
        
        let dataTask = performRequest(request: request, expectingStatusCode: code, completion: aCompletion)
        return dataTask
    }
    
    /// Array of TraktProtocol objects
    func performRequest<T>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTask? {
        
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
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
            do {
                let array = try decoder.decode([T].self, from: data)
                completion(.success(objects: array))
            } catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Array of ObjectsResultTypePagination objects
    func performRequest<T>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTask? {
        
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
            guard let data = data else { return completion(.error(error: TraktKitNoDataError)) }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
            do {
                let array = try decoder.decode([T].self, from: data)
                completion(.success(objects: array, currentPage: currentPage, limit: pageCount))
            } catch let jsonSerializationError as NSError {
                completion(.error(error: jsonSerializationError))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
}
