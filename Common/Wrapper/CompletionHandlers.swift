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
    public typealias paginatedCompletionHandler<T: Codable> = (_ result: ObjectsResultTypePagination<T>) -> Void
    
    public typealias DataResultCompletionHandler = (_ result: DataResultType) -> Void
    public typealias SuccessCompletionHandler = (_ result: SuccessResultType) -> Void
    public typealias CommentsCompletionHandler = paginatedCompletionHandler<Comment>
    public typealias CastCrewCompletionHandler = ObjectCompletionHandler<CastAndCrew>
    
    public typealias SearchCompletionHandler = ObjectsCompletionHandler<TraktSearchResult>
    public typealias statsCompletionHandler = ObjectCompletionHandler<TraktStats>
    
    // MARK: Shared
    public typealias UpdateCompletionHandler = paginatedCompletionHandler<Update>
    public typealias AliasCompletionHandler = ObjectsCompletionHandler<Alias>
    public typealias RatingDistributionCompletionHandler = ObjectCompletionHandler<RatingDistribution>
    
    // MARK: Calendar
    public typealias dvdReleaseCompletionHandler = ObjectsCompletionHandler<TraktDVDReleaseMovie>
    
    // MARK: Checkin
    public typealias checkinCompletionHandler = (_ result: CheckinResultType) -> Void
    
    // MARK: Shows
    public typealias TrendingShowsCompletionHandler = paginatedCompletionHandler<TraktTrendingShow>
    public typealias MostShowsCompletionHandler = paginatedCompletionHandler<TraktMostShow>
    public typealias AnticipatedShowCompletionHandler = paginatedCompletionHandler<TraktAnticipatedShow>
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
    public typealias TrendingMoviesCompletionHandler = paginatedCompletionHandler<TraktTrendingMovie>
    public typealias MostMoviesCompletionHandler = paginatedCompletionHandler<TraktMostMovie>
    public typealias AnticipatedMovieCompletionHandler = paginatedCompletionHandler<TraktAnticipatedMovie>
    public typealias MovieTranslationsCompletionHandler = ObjectsCompletionHandler<TraktMovieTranslation>
    public typealias WatchedMoviesCompletionHandler = paginatedCompletionHandler<TraktWatchedMovie>
    public typealias BoxOfficeMoviesCompletionHandler = ObjectsCompletionHandler<TraktBoxOfficeMovie>
    
    // MARK: Sync
    public typealias LastActivitiesCompletionHandler = ObjectCompletionHandler<TraktLastActivities>
    public typealias RatingsCompletionHandler = ObjectsCompletionHandler<TraktRating>
    public typealias HistoryCompletionHandler = paginatedCompletionHandler<TraktHistoryItem>
    public typealias CollectionCompletionHandler = ObjectsCompletionHandler<TraktCollectedItem>
    
    // MARK: Users
    public typealias ListCompletionHandler = ObjectCompletionHandler<TraktList>
    public typealias ListsCompletionHandler = ObjectsCompletionHandler<TraktList>
    public typealias ListItemCompletionHandler = ObjectsCompletionHandler<TraktListItem>
    public typealias WatchlistCompletionHandler = paginatedCompletionHandler<TraktListItem>
    public typealias HiddenItemsCompletionHandler = paginatedCompletionHandler<HiddenItem>
    public typealias UserCommentsCompletionHandler = ObjectsCompletionHandler<UsersComments>
    public typealias AddListItemCompletion = ObjectCompletionHandler<ListItemPostResult>
    public typealias RemoveListItemCompletion = ObjectCompletionHandler<RemoveListItemResult>
    public typealias FollowUserCompletion = ObjectCompletionHandler<FollowUserResult>
    public typealias FollowersCompletion = ObjectsCompletionHandler<FollowResult>
    public typealias FriendsCompletion = ObjectsCompletionHandler<Friend>
    public typealias WatchingCompletion = (_ result: WatchingResultType) -> Void
    public typealias UserStatsCompletion = ObjectCompletionHandler<UserStats>
    public typealias UserWatchedCompletion = ObjectsCompletionHandler<TraktWatchedItem>
    
    // MARK: - Perform Requests
    
    /// Data
    func performRequest(request: URLRequest, completion: @escaping DataResultCompletionHandler) -> URLSessionDataTaskProtocol? {
        let datatask = session._dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                200...299 ~= HTTPResponse.statusCode
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: nil))
                    }
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitNoDataError))
                return
            }
            completion(.success(data: data))
        }
        datatask.resume()

        return datatask
    }
    
    /// Success / Failure
    func performRequest(request: URLRequest, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        let datatask = session._dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else {
                completion(.fail)
                return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                200...299 ~= HTTPResponse.statusCode
                else {
                    completion(.fail)
                    return
            }
            
            completion(.success)
        }
        datatask.resume()
        
        return datatask
    }
    
    /// Checkin
    func performRequest(request: URLRequest, completion: @escaping checkinCompletionHandler) -> URLSessionDataTaskProtocol? {

        let datatask = session._dataTask(with: request) { [weak self] data, response, error in
            guard let welf = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }

            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitNoDataError))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)

            if let checkin = try? decoder.decode(TraktCheckin.self, from: data) {
                completion(.success(checkin: checkin))
                return
            } else if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let jsonDictionary = jsonObject as? RawJSON,
                let expirationDateString = jsonDictionary["expires_at"] as? String,
                let expirationDate = try? Date.dateFromString(expirationDateString) {
                completion(.checkedIn(expiration: expirationDate))
                return
            }

            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                200...299 ~= HTTPResponse.statusCode
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: nil))
                    }
                    return
            }

            completion(.error(error: nil))
        }
        datatask.resume()
        return datatask
    }
    
    // Generic array of Trakt objects
    func performRequest<T>(request: URLRequest, completion: @escaping  ((_ result: ObjectResultType<T>) -> Void)) -> URLSessionDataTaskProtocol? {
        
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
        
        let dataTask = performRequest(request: request, completion: aCompletion)
        return dataTask
    }
    
    /// Array of TraktProtocol objects
    func performRequest<T: Decodable>(request: URLRequest, completion: @escaping  ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTaskProtocol? {
        
        let dataTask = session._dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                200...299 ~= HTTPResponse.statusCode
                else {
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion(.error(error: welf.createErrorWithStatusCode(HTTPResponse.statusCode)))
                    } else {
                        completion(.error(error: nil))
                    }
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
    func performRequest<T>(request: URLRequest, completion: @escaping  ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTaskProtocol? {
        
        let dataTask = session._dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let welf = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                200...299 ~= HTTPResponse.statusCode
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
            guard let data = data else {
                completion(.error(error: TraktKitNoDataError))
                return
            }
            
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
    func performRequest(request: URLRequest, completion: @escaping WatchingCompletion) -> URLSessionDataTaskProtocol? {
        let dataTask = session._dataTask(with: request) { data, response, error in
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
