//
//  Sync.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    func createJsonData(movies movies: [String], shows: [String], episodes: [String]) -> NSData? {
        var jsonString = String()
        
        jsonString += "{" // Beginning
        jsonString += "\"movies\": [" // Begin Movies
        jsonString += movies.joinWithSeparator(",") // Add Movies
        jsonString += "]," // End Movies
        jsonString += "\"shows\": [" // Begin Shows
        jsonString += shows.joinWithSeparator(",") // Add Shows
        jsonString += "]," // End Shows
        jsonString += "\"episodes\": [" // Begin Episodes
        jsonString += episodes.joinWithSeparator(",") // Add Episodes
        jsonString += "]" // End Episodes
        jsonString += "}" // End
        
        #if DEBUG
            print(jsonString)
        #endif
        return jsonString.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    /**
     Returns dictionary of dates when content was last updated
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter completion: completion block
     
     - returns: NSURLSessionDataTask?
     */
    public func lastActivities(completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        
        guard let request = mutableRequestForURL("sync/last_activities", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completion(dictionary: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(dictionary: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: dictionary, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(dictionary: nil, error: jsonSerializationError)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }
        dataTask.resume()
        
        return dataTask
    }
    
    // MARK: - Playback
    
    /**
     Whenever a scrobble is paused, the playback progress is saved. Use this progress to sync up playback across different media centers or apps. For example, you can start watching a movie in a media center, stop it, then resume on your tablet from the same spot. Each item will have the progress percentage between 0 and 100.
     
     You can optionally specify a type to only get movies or episodes.
     
     By default, all results will be returned. However, you can send a limit if you only need a few recent results for something like an "on deck" feature.
     
     Status Code: 200
     
     OAuth: Required
     
     - parameter type: Possible Values: .Movies, .Episodes
     */
    public func getPlaybackProgress(type: WatchedType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/playback/\(type)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(objects: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: array, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
        }
        dataTask.resume()
        
        return dataTask
    }
    
    /**
     Remove a playback item from a user's playback progress list. A 404 will be returned if the id is invalid.
     
     Status Code: 204
     
     OAuth: Required
    */
    public func removePlaybackItem(id: NSNumber, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/playback/\(id)", authorization: true, HTTPMethod: "DELETE") else {
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completion(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNoContentToReturn else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    
                    completion(success: false)
                    
                    return
            }
            
            completion(success: true)

        }
        dataTask.resume()
        
        return dataTask
    }
    
    // MARK: - Collection
    
    /**
     Get all collected items in a user's collection. A collected item indicates availability to watch digitally or on physical media.
     
     If you add `?extended=metadata` to the URL, it will return the additional `media_type`, `resolution`, `audio`, `audio_channels` and '3d' metadata. It will use `null` if the metadata isn't set for an item.
     
     Status Code: 200
     
     OAuth: Required
    */
    public func getCollection(type: WatchedType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection/\(type)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(objects: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: array, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /**
     Add items to a user's collection. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be collected. If seasons are specified, all episodes in those seasons will be collected.
     
     Send a `collected_at` UTC datetime to mark items as collected in the past. You can also send additional metadata about the media itself to have a very accurate collection. Showcase what is available to watch from your epic HD DVD collection down to your downloaded iTunes movies.
     
     **Note**: You can resend items already in your collection and they will be updated with any new values. This includes the `collected_at` and any other metadata.
     
     Status Code: 201
     
     OAuth: Required
     */
    public func addToCollection(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection", authorization: true, HTTPMethod: "POST") else {
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                completion(success: false)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /**
     Remove one or more items from a user's collection.
     
     Status Code: 200
     
     OAuth: Required
     */
    public func removeFromCollection(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection", authorization: true, HTTPMethod: "POST") else {
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                completion(success: false)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    // MARK: -
    
    /**
     Returns all movies or shows a user has watched.
     
     Status Code: 200
     
     OAuth: Required
     
     - parameter type: which type of content to receive
     
     - parameter completion: completion handler
     */
    public func getWatched(type: WatchedType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        //        let urlString = "https://api-v2launch.trakt.tv/users/Fischey/watched/shows?extended=full" // Use this to test show sync with
        guard let request = mutableRequestForURL("sync/watched/\(type.rawValue)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    
                    completion(objects: [], error: nil)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(objects: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: array, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }
        dataTask.resume()
        
        return dataTask
    }
    
    // MARK: - History
    
    /**
     Returns movies and episodes that a user has watched, sorted by most recent. You can optionally limit the `type` to `movies` or `episodes`. The `id` in each history item uniquely identifies the event and can be used to remove individual events by using the POST /sync/history/remove method. The action will be set to scrobble, checkin, or watch.
     
     Specify a type and trakt id to limit the history for just that item. If the id is valid, but there is no history, an empty array will be returned.
     */
    public func getHistory(type: WatchedType?, traktID: NSNumber?, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        var path = "sync/history"
        if let type = type {
            path += type.rawValue
        }
        
        if let traktID = traktID {
            path += "\(traktID)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        let dataRequest = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(objects: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print("[\(__FUNCTION__)] \(response)")
                    #endif
                    
                    completion(objects: [], error: nil)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(objects: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [[String: AnyObject]] {
                    completion(objects: array, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(objects: nil, error: jsonSerializationError)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
            }
        }
        dataRequest.resume()
        
        return dataRequest
    }
    
    /**
     Add items to a user's watch history.
     
     Status Code: 201
     
     OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter completion: completion handler
     */
    public func addToHistory(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        
        // Request
        guard let request = mutableRequestForURL("sync/history", authorization: true, HTTPMethod: "POST") else {
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        let dataRequest = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                completion(success: false)
            }
        }
        dataRequest.resume()
        
        return dataRequest
    }
    
    /**
     Removes items from a user's watch history including watches, scrobbles, and checkins.
     
     Status Code: 200
     
     OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter completion: completion handler
     */
    public func removeFromHistory(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) {
        
        // Request
        guard let request = mutableRequestForURL("sync/history/remove", authorization: true, HTTPMethod: "POST") else {
            return
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: true)
            }
            catch {
                #if DEBUG
                    print("[\(__FUNCTION__)] Catched something")
                #endif
                
                completion(success: false)
            }
            }.resume()
    }
    
    // MARK: - Ratings
    
    /**
     Get a user's ratings filtered by type. You can optionally filter for a specific rating between 1 and 10.
    */
    public func getRatings() {
        
    }
    
    /**
     Rate one or more items. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be rated. If seasons are specified, all of those seasons will be rated.
     
     Send a `rated_at` UTC datetime to mark items as rated in the past. This is useful for syncing ratings from a media center.
    */
    public func addRatings() {
        
    }
    
    /**
     Remove ratings for one or more items.
    */
    public func removeRatings() {
        
    }
    
    // MARK: - Watchlist
    
    /**
     Returns all items in a user's watchlist filtered by type. When an item is watched, it will be automatically removed from the watchlist. To track what the user is actively watching, use the progress APIs.
    */
    public func getWatchlist(watchType: WatchedType, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/watchlist/\(watchType)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        let datatask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(dictionary: nil, error: error)
                return
            }
            
            // Check response
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.success else {
                    #if DEBUG
                        print(response)
                    #endif
                    
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        completion(dictionary: nil, error: self.createTraktErrorWithStatusCode(HTTPResponse.statusCode))
                    }
                    else {
                        completion(dictionary: nil, error: nil)
                    }
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(dictionary: nil, error: TraktKitNoDataError)
                return
            }
            
            do {
                if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(dictionary: dict, error: nil)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(jsonSerializationError)")
                #endif
                completion(dictionary: nil, error: jsonSerializationError)
            }
        }
        
        datatask.resume()
        return datatask
    }
    
    /**
     Add one of more items to a user's watchlist. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be added. If seasons are specified, all of those seasons will be added.
     
     Status Code: 201
     
     OAuth: Required
    */
    public func addToWatchlist(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        
        // Request
        guard let request = mutableRequestForURL("sync/watchlist", authorization: true, HTTPMethod: "POST") else {
            completion(success: false)
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /**
     Remove one or more items from a user's watchlist.
     
     Status Code: 201
     
     OAuth: Required
     */
    public func removeFromWatchlist(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/watchlist/remove", authorization: true, HTTPMethod: "POST") else {
            completion(success: false)
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
}
