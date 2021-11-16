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
    
    public enum ProgressResultType {
        case success
        case fail(Int)
    }
    
    public enum WatchingResultType {
        case checkedIn(watching: TraktWatching)
        case notCheckedIn
        case error(error: Error?)
    }
    
    public enum CheckinResultType {
        case success(checkin: TraktCheckinResponse)
        case checkedIn(expiration: Date)
        case error(error: Error?)
    }
    
    public enum TraktKitError: Error {
        case couldNotParseData
        case handlingRetry
    }
    
    public enum TraktError: Error {
        /// Bad Request - request couldn't be parsed
        case badRequest
        /// Oauth must be provided
        case unauthorized
        /// Forbidden - invalid API key or unapproved app
        case forbidden
        /// Not Found - method exists, but no record found
        case noRecordFound
        /// Method Not Found - method doesn't exist
        case noMethodFound
        /// Conflict - resource already created
        case resourceAlreadyCreated
        /// Locked User Account - have the user contact support
        case accountLocked
        /// VIP Only - user must upgrade to VIP
        case vipOnly
        /// Rate Limit Exceeded
        case rateLimitExceeded(HTTPURLResponse)
        /// Service Unavailable - server overloaded (try again in 30s)
        case serverOverloaded
        /// Service Unavailable - Cloudflare error
        case cloudflareError
        /// Full url response
        case unhandled(HTTPURLResponse)
    }
    
    // MARK: - Completion handlers
    
    // MARK: Common
    public typealias ObjectCompletionHandler<T: Codable> = (_ result: ObjectResultType<T>) -> Void
    public typealias ObjectsCompletionHandler<T: Codable> = (_ result: ObjectsResultType<T>) -> Void
    public typealias paginatedCompletionHandler<T: Codable> = (_ result: ObjectsResultTypePagination<T>) -> Void
    
    public typealias DataResultCompletionHandler = (_ result: DataResultType) -> Void
    public typealias SuccessCompletionHandler = (_ result: SuccessResultType) -> Void
    public typealias ProgressCompletionHandler = (_ result: ProgressResultType) -> Void
    public typealias CommentsCompletionHandler = paginatedCompletionHandler<Comment>
//    public typealias CastCrewCompletionHandler = ObjectCompletionHandler<CastAndCrew>
    
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
    
    // MARK: - Error handling
    
    private func handleResponse(response: URLResponse?, retry: @escaping (() -> Void)) throws {
        guard let httpResponse = response as? HTTPURLResponse else { throw TraktKitError.couldNotParseData }
        
        guard 200...299 ~= httpResponse.statusCode else {
            switch httpResponse.statusCode {
            case StatusCodes.BadRequest:
                throw TraktError.badRequest
            case StatusCodes.Unauthorized:
                throw TraktError.unauthorized
            case StatusCodes.Forbidden:
                throw TraktError.forbidden
            case StatusCodes.NotFound:
                throw TraktError.noRecordFound
            case StatusCodes.MethodNotFound:
                throw TraktError.noMethodFound
            case StatusCodes.Conflict:
                throw TraktError.resourceAlreadyCreated
            case StatusCodes.acountLocked:
                throw TraktError.accountLocked
            case StatusCodes.vipOnly:
                throw TraktError.vipOnly
            case StatusCodes.RateLimitExceeded:
                if let retryAfter = httpResponse.allHeaderFields["retry-after"] as? String,
                   let retryInterval = TimeInterval(retryAfter) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
                        retry()
                    }
                    /// To ensure completionHandler isn't called when retrying.
                    throw TraktKitError.handlingRetry
                } else {
                    throw TraktError.rateLimitExceeded(httpResponse)
                }
                
            case 503, 504:
                throw TraktError.serverOverloaded
            case 500...600:
                throw TraktError.cloudflareError
            default:
                throw TraktError.unhandled(httpResponse)
            }
            return
        }
    }
    
    // MARK: - Perform Requests
    
    /// Data
    func performRequest(request: URLRequest, completion: @escaping DataResultCompletionHandler) -> URLSessionDataTaskProtocol? {
        let datatask = session._dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            // Check response
            do {
                try self.handleResponse(response: response, retry: {
                    _ = self.performRequest(request: request, completion: completion)
                })
            } catch {
                switch error {
                case TraktKitError.handlingRetry:
                    break
                default:
                    completion(.error(error: error))
                }
                return
            }
            
            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitError.couldNotParseData))
                return
            }
            completion(.success(data: data))
        }
        datatask.resume()
        return datatask
    }
    
    /// Success / Failure
    func performRequest(request: URLRequest, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        let datatask = session._dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                completion(.fail)
                return
            }
            
            // Check response
            do {
                try self.handleResponse(response: response, retry: {
                    _ = self.performRequest(request: request, completion: completion)
                })
            } catch {
                switch error {
                case TraktKitError.handlingRetry:
                    break
                default:
                    completion(.fail)
                }
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
            guard let self = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }

            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitError.couldNotParseData))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)

            if let checkin = try? decoder.decode(TraktCheckinResponse.self, from: data) {
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
            do {
                try self.handleResponse(response: response, retry: {
                    _ = self.performRequest(request: request, completion: completion)
                })
            } catch {
                switch error {
                case TraktKitError.handlingRetry:
                    break
                default:
                    completion(.error(error: error))
                }
                return
            }

            completion(.error(error: nil))
        }
        datatask.resume()
        return datatask
    }
    
    // Generic array of Trakt objects
    func performRequest<T>(request: URLRequest, completion: @escaping ((_ result: ObjectResultType<T>) -> Void)) -> URLSessionDataTaskProtocol? {
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
    func performRequest<T: Decodable>(request: URLRequest, completion: @escaping ((_ result: ObjectsResultType<T>) -> Void)) -> URLSessionDataTaskProtocol? {
        let dataTask = session._dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            // Check response
            do {
                try self.handleResponse(response: response, retry: {
                    _ = self.performRequest(request: request, completion: completion)
                })
            } catch {
                switch error {
                case TraktKitError.handlingRetry:
                    break
                default:
                    completion(.error(error: error))
                }
                return
            }
            
            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitError.couldNotParseData))
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
    func performRequest<T>(request: URLRequest, completion: @escaping ((_ result: ObjectsResultTypePagination<T>) -> Void)) -> URLSessionDataTaskProtocol? {
        let dataTask = session._dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return completion(.error(error: nil)) }
            
            // Check response
            do {
                try self.handleResponse(response: response, retry: {
                    _ = self.performRequest(request: request, completion: completion)
                })
            } catch {
                switch error {
                case TraktKitError.handlingRetry:
                    break
                default:
                    completion(.error(error: error))
                }
                return
            }
            
            var pageCount: Int = 0
            if let pCount = httpResponse.allHeaderFields["x-pagination-page-count"] as? String,
                let pCountInt = Int(pCount) {
                pageCount = pCountInt
            }
            
            var currentPage: Int = 0
            if let cPage = httpResponse.allHeaderFields["x-pagination-page"] as? String,
                let cPageInt = Int(cPage) {
                currentPage = cPageInt
            }
            
            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitError.couldNotParseData))
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
        let dataTask = session._dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                completion(.error(error: error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return completion(.error(error: nil)) }
            
            // Check response
            do {
                try self.handleResponse(response: response, retry: {
                    _ = self.performRequest(request: request, completion: completion)
                })
            } catch {
                switch error {
                case TraktKitError.handlingRetry:
                    break
                default:
                    completion(.error(error: error))
                }
                return
            }
            
            if httpResponse.statusCode == StatusCodes.SuccessNoContentToReturn {
                completion(.notCheckedIn)
                return
            }
            
            // Check data
            guard let data = data else {
                completion(.error(error: TraktKitError.couldNotParseData))
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
