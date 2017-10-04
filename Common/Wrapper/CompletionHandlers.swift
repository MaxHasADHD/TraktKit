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
    case error(error: Error?)
}

/// Generic results type
public enum ObjectsResultType<T: Codable> {
    case success(objects: [T])
    case error(error: Error?)
}

/// Generic results type + Pagination
public enum ObjectsResultTypePagination<T: Codable> {
    case success(objects: [T], currentPage: Int, limit: Int)
    case error(error: Error?)
}

extension TraktManager {
    
    // MARK: - Result Types
    
    public enum DataResultType {
        case success(data: Data)
        case error(error: Error?)
    }
    
    public enum SuccessResultType {
        case success
        case fail
    }
    
    public enum WatchingResultType {
        case checkedIn(watching: TraktWatching)
        case notCheckedIn
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
    public typealias CommentsCompletionHandler = ObjectsCompletionHandler<Comment>
    public typealias CastCrewCompletionHandler = ObjectCompletionHandler<CastAndCrew>
    
    public typealias SearchCompletionHandler = ObjectsCompletionHandler<TraktSearchResult>
    public typealias statsCompletionHandler = ObjectCompletionHandler<TraktStats>
    
    // MARK: Shared
    public typealias UpdateCompletionHandler = ObjectsCompletionHandler<Update>
    public typealias AliasCompletionHandler = ObjectsCompletionHandler<Alias>
    public typealias RatingDistributionCompletionHandler = ObjectCompletionHandler<RatingDistribution>
    
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
    public typealias EpisodeCompletionHandler = ObjectCompletionHandler<TraktEpisode>
    public typealias EpisodesCompletionHandler = ObjectsCompletionHandler<TraktEpisode>
    
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
    public typealias HiddenItemsCompletionHandler = ObjectsCompletionHandler<HiddenItem>
    public typealias UserCommentsCompletionHandler = ObjectsCompletionHandler<UsersComments>
    public typealias AddListItemCompletion = ObjectCompletionHandler<ListItemPostResult>
    public typealias RemoveListItemCompletion = ObjectCompletionHandler<RemoveListItemResult>
    public typealias FollowUserCompletion = ObjectCompletionHandler<FollowUserResult>
    public typealias FollowersCompletion = ObjectsCompletionHandler<FollowUserResult>
    public typealias FriendsCompletion = ObjectsCompletionHandler<Friend>
    public typealias WatchingCompletion = (_ result: WatchingResultType) -> Void
    public typealias UserStatsCompletion = ObjectCompletionHandler<UserStats>
    
    // MARK: - Perform Requests
    
    /// Data
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping DataResultCompletionHandler) -> URLSessionDataTask? {
        
        let datatask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else { return completion(.error(error: error)) }
            
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
                    completion(.error(error: error))
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
            guard error == nil else { return completion(.error(error: error)) }
            
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
            } catch {
                completion(.error(error: error))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /// Array of ObjectsResultTypePagination objects
    func performRequest<T>(request: URLRequest, expectingStatusCode code: Int, completion: @escaping  ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTask? {
        
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else { return completion(.error(error: error)) }
            
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
            } catch {
                completion(.error(error: error))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    // Watching
    func performRequest(request: URLRequest, expectingStatusCode code: Int, completion: @escaping WatchingCompletion) -> URLSessionDataTask? {
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == StatusCodes.Success ||
                    HTTPResponse.statusCode == StatusCodes.SuccessNoContentToReturn
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: self.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: TraktKitNoDataError))
                    }
                    return
            }
            
            if HTTPResponse.statusCode == StatusCodes.SuccessNoContentToReturn {
                completion(.notCheckedIn)
                return
            }
            
            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitNoDataError))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
            do {
                let watching = try decoder.decode(TraktWatching.self, from: data)
                completion(.checkedIn(watching: watching))
            } catch {
                completion(.error(error: error))
            }
        }
        dataTask.resume()
        return dataTask
    }
}
