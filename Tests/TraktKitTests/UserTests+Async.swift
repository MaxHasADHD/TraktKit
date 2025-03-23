//
//  UserTests+Async.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/8/25.
//

import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct UserTestSuite {
        @Test func getSettings() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/settings", result: .success(jsonData(named: "test_get_settings")))

            let settings = try await traktManager.currentUser().settings().perform()
            #expect(settings.user.name == "Justin Nemeth")
            #expect(settings.user.gender == "male")
            #expect(settings.connections.twitter == true)
            #expect(settings.connections.slack == false)
            #expect(settings.limits.list.count == 2)
            #expect(settings.limits.list.itemCount == 100)
        }

        // MARK: - Follow requests

        @Test func getFollowingRequests() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/requests", result: .success(jsonData(named: "test_get_follow_request")))

            let followRequests = try await traktManager.currentUser()
                .getFollowerRequests()
                .perform()

            #expect(followRequests.count == 1)
        }

        @Test func approveFollowRequest() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/requests/123", result: .success(jsonData(named: "test_approve_follow_request")))

            let result = try await traktManager.currentUser()
                .approveFollowRequest(id: 123)
                .perform()

            #expect(result.user.username == "sean")
        }

        @Test func denyFollowRequest() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.DELETE, "https://api.trakt.tv/users/requests/123", result: .success(.init()))

            try await traktManager.currentUser()
                .denyFollowRequest(id: 123)
                .perform()
        }

        @Test func getSavedFilters() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/saved_filters", result: .success(jsonData(named: "test_get_saved_filters")))

            let filters = try await traktManager.currentUser().savedFilters().perform().object
            #expect(filters.count == 4)

            let firstFilter = try #require(filters.first)
            #expect(firstFilter.id == 101)
        }

        // MARK: - Hidden items

        @Test func getHiddenItems() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/hidden/progress_watched?page=1&limit=10&type=show&extended=min", result: .success(jsonData(named: "test_get_hidden_items")))

            let result = try await traktManager.currentUser()
                .hiddenItems(for: HiddenItemSection.progressWatched, type: "show")
                .page(1)
                .limit(10)
                .extend(.Min)
                .perform()
                .object

            #expect(result.count == 2)
        }

        @Test func hideItem() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.POST, "https://api.trakt.tv/users/hidden/calendar", result: .success(jsonData(named: "test_add_hidden_item")))

            let result = try await traktManager.currentUser()
                .hide(movies: [.init(trakt: 1234)], in: HiddenItemSection.calendar)
                .perform()

            #expect(result.added.movies == 1)
            #expect(result.added.shows == 2)
            #expect(result.added.seasons == 2)
        }

        @Test func unhideItem() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/hidden/calendar/remove", result: .success(jsonData(named: "test_post_remove_hidden_items")))

            let result = try await traktManager.currentUser()
                .unhide(movies: [.init(trakt: 1234)], in: HiddenItemSection.calendar)
                .perform()
            #expect(result.deleted.movies == 1)
            #expect(result.deleted.shows == 2)
            #expect(result.deleted.seasons == 2)
        }

        // MARK: - Profile

        @Test func getMinProfile() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/me?extended=min", result: .success(jsonData(named: "test_get_min_profile")))

            let profile = try await traktManager.currentUser()
                .profile()
                .extend(.Min)
                .perform()

            #expect(profile.username == "sean")
            #expect(profile.isPrivate == false)
            #expect(profile.isVIP == true)
            #expect(profile.isVIPEP == true)
            #expect(profile.name == "Sean Rudford")
        }

        @Test func getFullProfile() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/me?extended=full", result: .success(jsonData(named: "test_get_full_profile")), replace: true)

            let profile = try await traktManager.currentUser()
                .profile()
                .extend(.Full)
                .perform()

            #expect(profile.username == "sean")
            #expect(profile.isPrivate == false)
            #expect(profile.isVIP == true)
            #expect(profile.isVIPEP == true)
            #expect(profile.name == "Sean Rudford")
            #expect(profile.joinedAt != nil)
            #expect(profile.age == 35)
            #expect(profile.about == "I have all your cassette tapes.")
            #expect(profile.location == "SF")
            #expect(profile.gender == "male")
        }

        @Test func getVIPProfile() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/me?extended=full", result: .success(jsonData(named: "test_get_VIP_profile")), replace: true)

            let profile = try await traktManager.currentUser()
                .profile()
                .extend(.Full)
                .perform()

            #expect(profile.username == "sean")
            #expect(profile.isPrivate == false)
            #expect(profile.isVIP == true)
            #expect(profile.isVIPEP == true)
            #expect(profile.name == "Sean Rudford")
            #expect(profile.vipYears == 5)
            #expect(profile.vipOG == true)
        }

        // MARK: - Collection

        @Test func getCollection() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/me/collection/shows", result: .success(jsonData(named: "test_get_user_collection")))

            let collection = try await traktManager.user("me")
                .collection(type: "shows")
                .perform()

            let shows = collection.map { $0.show }
            let seasons = collection.map { $0.seasons }
            #expect(shows.count == 2)
            #expect(seasons.count == 2)

            let firstItemMetadata = try #require(collection.first(where: { $0.show?.ids.trakt == 245 })?.seasons?.first?.episodes.first?.metadata)

            #expect(firstItemMetadata.mediaType == .bluray)
            #expect(firstItemMetadata.resolution == nil)
            #expect(firstItemMetadata.hdr == nil)
            #expect(firstItemMetadata.audio == .dtsHDMA)
            #expect(firstItemMetadata.audioChannels == nil)
            #expect(firstItemMetadata.is3D == false)
        }

        // MARK: - Comments

        @Test func getComments() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/sean/comments", result: .success(jsonData(named: "test_get_user_comments")))

            let comments = try await traktManager.user("sean")
                .comments()
                .perform()
                .object

            #expect(comments.count == 5)
        }

        // MARK: - List

        @Test func getCustomList() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/me/lists/star-wars-in-machete-order", result: .success(jsonData(named: "test_get_custom_list")))

            let customList = try await traktManager.currentUser().personalList("star-wars-in-machete-order").perform()
            #expect(customList.name == "Star Wars in machete order")
            #expect(customList.description != nil)
        }

        @Test func getListItems() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/sean/lists/star-wars-in-machete-order/items", result: .success(jsonData(named: "test_get_items_on_custom_list")))

            let listItems = try await traktManager.user("sean").itemsOnList("star-wars-in-machete-order").perform().object
            #expect(listItems.count == 5)
        }

        @Test func addItemsToList() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.POST, "https://api.trakt.tv/users/me/lists/star-wars-in-machete-order/items", result: .success(jsonData(named: "test_add_item_to_custom_list")))

            // For the test we don't need to add any specific Ids.
            let response = try await traktManager.currentUser().addItemsToList("star-wars-in-machete-order", movies: []).perform()
            #expect(response.added.seasons == 1)
            #expect(response.added.people == 1)
            #expect(response.added.movies == 1)
            #expect(response.added.shows == 1)
            #expect(response.added.episodes == 2)

            #expect(response.existing.seasons == 0)
            #expect(response.existing.episodes == 0)
            #expect(response.existing.movies == 0)
            #expect(response.existing.shows == 0)
            #expect(response.existing.episodes == 0)

            #expect(response.notFound.movies.count == 1)
        }

        @Test func removeItemsFromList() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.DELETE, "https://api.trakt.tv/users/me/lists/star-wars-in-machete-order/items/remove", result: .success(jsonData(named: "test_remove_item_from_custom_list")))

            // For the test we don't need to add any specific Ids.
            let response = try await traktManager.currentUser().removeItemsFromList("star-wars-in-machete-order", movies: []).perform()
            #expect(response.deleted.seasons == 1)
            #expect(response.deleted.people == 1)
            #expect(response.deleted.movies == 1)
            #expect(response.deleted.shows == 1)
            #expect(response.deleted.episodes == 2)

            #expect(response.notFound.movies.count == 1)
        }

        // MARK: - History

        @Test func getWatchedHistory() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/sean/history?extended=min", result: .success(jsonData(named: "test_get_user_watched_history")))

            let history = try await traktManager.user("sean")
                .watchedHistory()
                .extend(.Min)
                .perform()
                .object

            #expect(history.count == 3)
        }

        // MARK: - Ratings

        @Test func getRatings() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/sean/ratings", result: .success(jsonData(named: "test_get_user_ratings")))

            let ratings = try await traktManager.user("sean")
                .ratings()
                .perform()
                .object

            #expect(ratings.count == 2)
        }

        // MARK: - Watchlist

        @Test func getWatchlist() async throws {
            let traktManager = await authenticatedTraktManager()
            try mock(.GET, "https://api.trakt.tv/users/sean/watchlist/movies?extended=min", result: .success(jsonData(named: "test_get_user_watchlist")))

            let watchlist = try await traktManager.user("sean")
                .watchlist(type: "movies")
                .extend(.Min)
                .perform()
                .object

            #expect(watchlist.count == 5)
        }
    }
}
