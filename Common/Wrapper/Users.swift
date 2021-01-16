//
//  Users.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/18/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

/**
 User's with public data will return info with all GET methods. Private user's (inlcuding yourself) require valid OAuth and a friend relationship to return data.
 
 **Special username for the OAuth user**
 
 If you send valid OAuth, you can use `me` for the username to identify the OAuth user instead of needing their actual username. You can of course still use their actual username, it's up to you.
 
 **Creating New Users**
 
 Since the API uses OAuth, users can create a new account during that flow if they need to. As far as your app is concerned, you'll still receive OAuth tokens no matter if they sign in with an existing account or create a new one.
 */
extension TraktManager {
    
    // MARK: - Settings
    
    /**
     Get the user's settings so you can align your app's experience with what they're used to on the trakt website.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func getSettings(completion: @escaping ObjectCompletionHandler<AccountSettings>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "users/settings",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Follower Requests
    
    /**
     List a user's pending follow requests so they can either approve or deny them.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func getFollowRequests(completion: @escaping ObjectsCompletionHandler<FollowRequest>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "users/requests",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Approve or Deny follower Requests
    
    /**
     Approve a follower using the `id` of the request. If the `id` is not found, was already approved, or was already denied, a `404` error will be returned.
     
     🔒 OAuth Required
    
    - parameter id: ID of the follower request. Example: `123`.
     */
    @discardableResult
    public func approveFollowRequest(requestID id: NSNumber, completion: @escaping ObjectCompletionHandler<FollowResult>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "users/requests/\(id)",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .POST) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Deny a follower using the `id` of the request. If the `id` is not found, was already approved, or was already denied, a `404` error will be returned.
     
     🔒 OAuth Required
     
     - parameter id: ID of the follower request. Example: `123`.
     */
    @discardableResult
    public func denyFollowRequest(requestID id: NSNumber, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "users/requests/\(id)",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .DELETE) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Hidden Items
    
    /**
     Get hidden items for a section. This will return an array of standard media objects. You can optionally limit the `type` of results to return.
     
     🔒 OAuth Required
     📄 Pagination
     ✨ Extended Info
     */
    @discardableResult
    public func hiddenItems(section: SectionType, type: HiddenItemsType? = nil, extended: [ExtendedType] = [.Min], pagination: Pagination? = nil, completion: @escaping HiddenItemsCompletionHandler) -> URLSessionDataTaskProtocol? {
        var query: [String: String] = ["extended": extended.queryString()]
        if let type = type {
            query["type"] = type.rawValue
        }

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard var request = mutableRequest(forPath: "users/hidden/\(section.rawValue)",
            withQuery: query,
            isAuthorized: true,
            withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Hide items for a specific section. Here's what type of items can hidden for each section.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func hide(movies: [SyncId]? = nil, shows: [SyncId]? = nil, seasons: [SyncId]? = nil, from section: SectionType, completion: @escaping ObjectCompletionHandler<HideItemResult>) throws -> URLSessionDataTaskProtocol? {
        let body = TraktMediaBody(movies: movies, shows: shows, seasons: seasons)
        guard let request = post("users/hidden/\(section.rawValue)", body: body) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Unhide items for a specific section. Here's what type of items can unhidden for each section.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func unhide(movies: [SyncId]? = nil, shows: [SyncId]? = nil, seasons: [SyncId]? = nil, from section: SectionType, completion: @escaping ObjectCompletionHandler<UnhideItemResult>) throws -> URLSessionDataTaskProtocol? {
        let body = TraktMediaBody(movies: movies, shows: shows, seasons: seasons)
        guard let request = post("users/hidden/\(section.rawValue)/remove", body: body) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Likes
    
    /**
     Get items a user likes. This will return an array of standard media objects. You can optionally limit the `type` of results to return.
     
     🔒 OAuth Required
     📄 Pagination
    
    - Parameter type: Possible values:  comments, lists.
     */
    @discardableResult
    public func getLikes(type: LikeType, completion: @escaping ObjectsCompletionHandler<Like>) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "users/likes/\(type.rawValue)",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Profile
    
    /**
     Get a user's profile information. If the user is private, info will only be returned if you send OAuth and are either that user or an approved follower.
     
     🔓 OAuth Optional
     */
    @discardableResult
    public func getUserProfile(username: String = "me", extended: [ExtendedType] = [.Min], completion: @escaping ObjectCompletionHandler<User>) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: "users/\(username)",
                                         withQuery: ["extended": extended.queryString()],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Collection
    
    /**
    Get all collected items in a user's collection. A collected item indicates availability to watch digitally or on physical media.
    
    If you add `?extended=metadata` to the URL, it will return the additional `media_type`, `resolution`, `audio`, `audio_channels` and '3d' metadata. It will use `null` if the metadata isn't set for an item.
    
    🔓 OAuth Optional
     */
    @discardableResult
    public func getUserCollection(username: String = "me", type: Type, completion: @escaping ObjectsCompletionHandler<TraktCollectedItem>) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: "users/\(username)/collection/\(type.rawValue)",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
    Returns comments a user has posted sorted by most recent.
    
    🔓 OAuth Optional
    📄 Pagination
    */
    @discardableResult
    public func getUserComments(username: String = "me", commentType: CommentType? = nil, type: Type2? = nil, pagination: Pagination? = nil, completion: @escaping UserCommentsCompletionHandler) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        var path = "users/\(username)/comments"
        if let commentType = commentType {
            path += "\(commentType.rawValue)/"

            if let mediaType = type {
                path += "\(mediaType.rawValue)"
            }
        }

        var query: [String: String] = [:]

        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }

        guard
            let request = mutableRequest(forPath: path,
                                         withQuery: query,
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Lists
    
    /**
    Returns all custom lists for a user. Use `users/:username/lists/:id/items` to get the actual items a specific list contains.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getCustomLists(username: String = "me", completion: @escaping ListsCompletionHandler) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard
            let request = mutableRequest(forPath: "users/\(username)/lists",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Create a new custom list. The `name` is the only required field, but the other info is recommended to ask for.
     
     🔒 OAuth Required
     
     - parameter listName: Name of the list.
     - parameter listDescription: Description for this list.
     - parameter privacy: `private`, `friends`, or `public`
     - parameter displayNumbers: Should each item be numbered?
     - parameter allowComments: Are comments allowed?
     */
    @discardableResult
    public func createCustomList(listName: String, listDescription: String, privacy: String = "private", displayNumbers: Bool = false, allowComments: Bool = true, completion: @escaping ListCompletionHandler) throws -> URLSessionDataTaskProtocol? {
        
        // JSON
        let json: [String: Any] = [
            "name": listName,
            "description": listDescription,
            "privacy": privacy,
            "display_numbers": displayNumbers,
            "allow_comments": allowComments,
            ]
        
        // Request
        guard var request = mutableRequest(forPath: "users/me/lists", withQuery: [:], isAuthorized: true, withHTTPMethod: .POST) else { return nil }
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - List
    
    /**
    Returns a single custom list. Use `users/:username/lists/:id/items` to get the actual items this list contains.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getCustomList<T: CustomStringConvertible>(username: String = "me", listID: T, completion: @escaping ObjectCompletionHandler<TraktList>) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard
            let request = mutableRequest(forPath: "users/\(username)/lists/\(listID)",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Update a custom list by sending 1 or more parameters. If you update the list name, the original slug will still be retained so existing references to this list won't break.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func updateCustomList<T: CustomStringConvertible>(listID: T, listName: String? = nil, listDescription: String? = nil, privacy: String? = nil, displayNumbers: Bool? = nil, allowComments: Bool? = nil, completion: @escaping ListCompletionHandler) throws -> URLSessionDataTaskProtocol? {
        
        // JSON
        var json = [String: Any]()
        json["name"] = listName
        json["description"] = listDescription
        json["privacy"] = privacy
        json["display_numbers"] = displayNumbers
        json["allow_comments"] = allowComments
        
        // Request
        guard var request = mutableRequest(forPath: "users/me/lists/\(listID)", withQuery: [:], isAuthorized: true, withHTTPMethod: .PUT) else { return nil }
        request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Remove a custom list and all items it contains.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func deleteCustomList<T: CustomStringConvertible>(username: String = "me", listID: T, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "users/\(username)/lists/\(listID)",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .DELETE) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - List Like
    
    /**
    Votes help determine popular lists. Only one like is allowed per list per user.
    
    🔒 OAuth Required
    */
    @discardableResult
    public func likeList<T: CustomStringConvertible>(username: String = "me", listID: T, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "users/\(username)/lists/\(listID)/like",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .POST) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Remove a like on a list.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func removeListLike<T: CustomStringConvertible>(username: String = "me", listID: T, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "users/\(username)/lists/\(listID)/like",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .DELETE) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - List Items
    
    /**
    Get all items on a custom list. Items can be movies, shows, seasons, episodes, or people.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getItemsForCustomList<T: CustomStringConvertible>(username: String = "me", listID: T, type: [ListItemType]? = nil, extended: [ExtendedType] = [.Min], completion: @escaping ListItemCompletionHandler) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        var path = "users/\(username)/lists/\(listID)/items"
        
        if let types = type, types.isEmpty == false {
            let value = types.map { $0.rawValue }.joined(separator: ",")
            path += "/\(value)"
        }
        
        guard let request = mutableRequest(forPath: path,
                                         withQuery: ["extended": extended.queryString()],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Add one or more items to a custom list. Items can be movies, shows, seasons, episodes, or people.
     
     🔒 OAuth Required
     
     - parameter movies: Array of movie Trakt ids
     - parameter shows: Array of show Trakt ids
     - parameter seasons: Array of season Trakt ids
     - parameter episodes: Array of episode Trakt ids
     - parameter people: Array of people Trakt ids
     */
    @discardableResult
    public func addItemToCustomList<T: CustomStringConvertible>(username: String = "me", listID: T, movies: [SyncId]? = nil, shows: [SyncId]? = nil, seasons: [SyncId]? = nil, episodes: [SyncId]? = nil, people: [SyncId]? = nil, completion: @escaping AddListItemCompletion) throws -> URLSessionDataTaskProtocol? {
        let body = TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes, people: people)
        guard let request = post("users/\(username)/lists/\(listID)/items", body: body) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Remove List Items
    
    /**
    Remove one or more items from a custom list.
    
    🔒 OAuth Required
     
     - parameter movies: Array of movie Trakt ids
     - parameter shows: Array of show Trakt ids
     - parameter seasons: Array of season Trakt ids
     - parameter episodes: Array of episode Trakt ids
     - parameter people: Array of people Trakt ids
    */
    @discardableResult
    public func removeItemFromCustomList<T: CustomStringConvertible>(username: String = "me", listID: T, movies: [SyncId]? = nil, shows: [SyncId]? = nil, seasons: [SyncId]? = nil, episodes: [SyncId]? = nil, people: [SyncId]? = nil, completion: @escaping RemoveListItemCompletion) throws -> URLSessionDataTaskProtocol? {
        let body = TraktMediaBody(movies: movies, shows: shows, seasons: seasons, episodes: episodes, people: people)
        guard let request = post("users/\(username)/lists/\(listID)/items/remove", body: body) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - List Comments
    
    /**
    Returns all top level comments for a list. By default, the `newest` comments are returned first.
    
    📄 Pagination
    */
    @discardableResult
    public func getUserAllListComments(username: String = "me", listID: String, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard
            let request = mutableRequest(forPath: "users/\(username)/lists/\(listID)/comments",
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Follow
    
    /**
    If the user has a private profile, the follow request will require approval (`approved_at` will be null). If a user is public, they will be followed immediately (`approved_at` will have a date).
    
    **Note**: If this user is already being followed, a `409` HTTP status code will returned.
    
    🔒 OAuth Required
    */
    @discardableResult
    public func followUser(username: String, completion: @escaping FollowUserCompletion) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "users/\(username)/follow",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .POST) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    /**
     Unfollow someone you already follow.
     
     🔒 OAuth Required
     */
    @discardableResult
    public func unfollowUser(username: String, completion: @escaping SuccessCompletionHandler) -> URLSessionDataTaskProtocol? {
        guard let request = mutableRequest(forPath: "users/\(username)/follow",
                                         withQuery: [:],
                                         isAuthorized: true,
                                         withHTTPMethod: .DELETE) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Followers
    
    /**
    Returns all followers including when the relationship began.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getUserFollowers(username: String = "me", completion: @escaping FollowersCompletion) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: "users/\(username)/followers",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Following
    
    /**
    Returns all user's they follow including when the relationship began.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getUserFollowing(username: String = "me", completion: @escaping FollowersCompletion) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard
            let request = mutableRequest(forPath: "users/\(username)/following",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Friends
    
    /**
    Returns all friends for a user including when the relationship began. Friendship is a 2 way relationship where each user follows the other.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getUserFriends(username: String = "me", completion: @escaping FriendsCompletion) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: "users/\(username)/friends",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - History
    
    /**
    Returns movies and episodes that a user has watched, sorted by most recent. You can optionally limit the `type` to `movies` or `episodes`. The `id` in each history item uniquely identifies the event and can be used to remove individual events by using the **POST** /sync/history/remove method. The `action` will be set to `scrobble`, `checkin`, or `watch`.
    
    Specify a `type` and trakt `id` to limit the history for just that item. If the `id` is valid, but there is no history, an empty array will be returned.
    
    🔓 OAuth Optional
    📄 Pagination
    ✨ Extended Info
    */
    @discardableResult
    public func getUserWatchedHistory(username: String = "me", type: WatchedType? = nil, traktId: Int? = nil, startAt: Date? = nil, endAt: Date? = nil, extended: [ExtendedType] = [.Min], pagination: Pagination? = nil, completion: @escaping HistoryCompletionHandler) -> URLSessionDataTaskProtocol? {
        var path = "users/\(username)/history"
        
        if let type = type {
            path += "/\(type.rawValue)"
            
            if let id = traktId { // I think a type needs to be provided if an Id was specified
                path += "/\(id)"
            }
        }

        var query = ["extended": extended.queryString()]

        if let startDate = startAt {
            query["start_at"] = startDate.UTCDateString()
        }

        if let endDate = endAt {
            query["end_at"] = endDate.UTCDateString()
        }
     
        // pagination
        if let pagination = pagination {
            for (key, value) in pagination.value() {
                query[key] = value
            }
        }
        
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: path,
                                         withQuery: query,
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
    Get a user's ratings filtered by type. You can optionally filter for a specific rating between 1 and 10.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getUserRatings(username: String = "me", type: Type? = nil, rating: NSNumber? = nil, completion: @escaping RatingsCompletionHandler) -> URLSessionDataTaskProtocol? {
        
        var path = "users/\(username)/ratings"

        if let type = type {
            path += "/\(type.rawValue)"

            if let rating = rating {
                path += "/\(rating)"
            }
        }
        
        let authorization = username == "me" ? true : false
        guard
            let request = mutableRequest(forPath: path,
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Watchlist
    
    /**
    Returns all items in a user's watchlist filtered by type. When an item is watched, it will be automatically removed from the watchlist. To track what the user is actively watching, use the progress APIs.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getUserWatchlist(username: String = "me", type: WatchedType, extended: [ExtendedType] = [.Min], completion: @escaping ListItemCompletionHandler) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: "users/\(username)/watchlist/\(type.rawValue)",
                                         withQuery: ["extended": extended.queryString()],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
     Returns a movie or episode if the user is currently watching something. If they are not, it returns no data and a `204` HTTP status code.
     
     🔓 OAuth Optional
     */
    @discardableResult
    public func getUserWatching(username: String = "me", completion: @escaping WatchingCompletion) -> URLSessionDataTaskProtocol? {
        // Should this function have a special completion handler? If it returns no data it is obvious that the user
        // is not watching anything, but checking a boolean in the completion block is also nice
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: "users/\(username)/watching",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
    Returns all movies or shows a user has watched sorted by most plays.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getUserWatched(username: String = "me", type: Type, extended: [ExtendedType] = [.Min], completion: @escaping UserWatchedCompletion) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard var request = mutableRequest(forPath: "users/\(username)/watched/\(type.rawValue)",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: authorization,
                                           withHTTPMethod: .GET) else { return nil }
        request.timeoutInterval = 60*2 // 2 minutes
        return performRequest(request: request, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
    Returns stats about the movies, shows, and episodes a user has watched, collected, and rated.
    
    🔓 OAuth Optional
    */
    @discardableResult
    public func getUserStats(username: String = "me", completion: @escaping UserStatsCompletion) -> URLSessionDataTaskProtocol? {
        let authorization = username == "me" ? true : false
        guard let request = mutableRequest(forPath: "users/\(username)/stats",
                                         withQuery: [:],
                                         isAuthorized: authorization,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, completion: completion)
    }
}
