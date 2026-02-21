//
//  ShowsTests.swift
//  TraktKitTests
//
//  Created by Maximilian Litteral on 6/13/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Testing
import Foundation
@testable import TraktKit

extension TraktTestSuite {
    @Suite("Shows Tests")
    struct ShowsTests {
        let traktManager: TraktManager

        init() async throws {
            self.traktManager = await authenticatedTraktManager()
        }

        // MARK: - Trending

        @Test func getMinTrendingShowsAwait() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/trending?extended=min&page=1&limit=10", result: .success(jsonData(named: "TrendingShows_Min")), headers: [.page(1), .pageCount(100)])

            let response = try await traktManager.shows.trending()
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()
            let trendingShows = response.object
            #expect(trendingShows.count == 10)
            #expect(response.currentPage == 1)
            #expect(response.pageCount == 100)
            guard let firstTrendingShow = trendingShows.first else {
                Issue.record("No trending shows found")
                return
            }
            #expect(firstTrendingShow.watchers == 252)
            #expect(firstTrendingShow.show.title == "Marvel's Jessica Jones")
            #expect(firstTrendingShow.show.overview == nil)
        }

        @Test func getFullTrendingShows() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/trending?extended=full&page=1&limit=10", result: .success(jsonData(named: "TrendingShows_Full")))

            let response = try await traktManager.shows.trending()
                .extend(.Full)
                .page(1)
                .limit(10)
                .perform()
            let trendingShows = response.object
            #expect(trendingShows.count == 10)
            guard let firstTrendingShow = trendingShows.first else {
                Issue.record("No trending shows found")
                return
            }
            #expect(firstTrendingShow.watchers == 252)
            #expect(firstTrendingShow.show.title == "Marvel's Jessica Jones")
            #expect(firstTrendingShow.show.overview == "A former superhero decides to reboot her life by becoming a private investigator.")
        }

        // MARK: - Popular

        @Test func getPopularShows() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/popular?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_popular_shows")))

            let response = try await traktManager.shows
                .popular()
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()

            #expect(response.object.count == 10)
        }

        // MARK: - Played

        @Test func getMostPlayedShows() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/played/weekly?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_played_shows")))

            let response = try await traktManager.shows
                .played(period: .weekly)
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()

            #expect(response.object.count == 10)
        }

        // MARK: - Watched

        @Test func getMostWatchedShowsAsync() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/watched/weekly?page=1&limit=10", result: .success(jsonData(named: "test_get_most_watched_shows")), headers: [.page(1), .pageCount(8)])

            let pagedObject = try await traktManager.shows
                .watched(period: .weekly)
                .page(1)
                .limit(10)
                .perform()
            let (watchedShows, page, total) = (pagedObject.object, pagedObject.currentPage, pagedObject.pageCount)

            #expect(watchedShows.count == 10)
            #expect(page == 1)
            #expect(total == 8)
            guard let firstWatchedShow = watchedShows.first else {
                Issue.record("No watched shows found")
                return
            }
            #expect(firstWatchedShow.playCount == 8784154)
            #expect(firstWatchedShow.watcherCount == 203742)
        }

        // MARK: - Collected

        @Test func getMostCollectedShows() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/collected/weekly?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_collected_shows")))

            let response = try await traktManager.shows
                .collected(period: .weekly)
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()

            #expect(response.object.count == 10)
        }

        // MARK: - Anticipated

        @Test func getMostAnticipatedShows() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/anticipated?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_most_anticipated_shows")))

            let response = try await traktManager.shows
                .anticipated()
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()

            #expect(response.object.count == 10)
        }

        // MARK: - Updates

        @Test func getUpdatedShows() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/updates/2014-09-22T00:00:00?extended=min&page=1&limit=10", result: .success(jsonData(named: "test_get_updated_shows")), replace: true)

            let response = try await traktManager.shows
                .recentlyUpdated(since: try Date.dateFromString("2014-09-22"))
                .extend(.Min)
                .page(1)
                .limit(10)
                .perform()

            #expect(response.object.count == 2)
        }

        @Test func getUpdatedShowIds() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/updates/id/2025-01-01T00:00:00", result: .success(jsonData(named: "test_get_updated_shows_ids")))

            let updatedIds = try await traktManager.shows
                .recentlyUpdatedIds(since: try Date.dateFromString("2025-01-01"))
                .perform()
            #expect(updatedIds.object.count == 100)
            #expect(updatedIds.object.first == 163302)
        }

        // MARK: - Summary

        @Test func getMinShow() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones?extended=min", result: .success(jsonData(named: "Show_Min")))

            let show = try await traktManager.show(id: "game-of-thrones").summary()
                .extend(.Min)
                .perform()

            #expect(show.title == "Game of Thrones")
            #expect(show.year == 2011)
            #expect(show.ids.trakt == 353)
            #expect(show.ids.slug == "game-of-thrones")
            #expect(show.overview == nil)
            #expect(show.firstAired == nil)
            #expect(show.airs == nil)
            #expect(show.runtime == nil)
            #expect(show.certification == nil)
            #expect(show.network == nil)
            #expect(show.country == nil)
            #expect(show.trailer == nil)
            #expect(show.homepage == nil)
            #expect(show.status == nil)
            #expect(show.rating == nil)
            #expect(show.votes == nil)
            #expect(show.updatedAt == nil)
            #expect(show.language == nil)
            #expect(show.availableTranslations == nil)
            #expect(show.genres == nil)
            #expect(show.airedEpisodes == nil)
        }

        @Test func getFullShowAwait() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones?extended=full", result: .success(jsonData(named: "Show_Full")))

            let show = try await traktManager.show(id: "game-of-thrones").summary()
                .extend(.Full)
                .perform()

            #expect(show.title == "Game of Thrones")
            #expect(show.year == 2011)
            #expect(show.ids.trakt == 353)
            #expect(show.ids.slug == "game-of-thrones")
            #expect(show.overview != nil)
            #expect(show.firstAired != nil)
            #expect(show.airs?.day == "Sunday")
            #expect(show.airs?.time == "21:00")
            #expect(show.airs?.timezone == "America/New_York")
            #expect(show.runtime == 60)
            #expect(show.certification == "TV-MA")
            #expect(show.network == "HBO")
            #expect(show.country == "us")
            #expect(show.updatedAt != nil)
            #expect(show.trailer == nil)
            #expect(show.homepage?.absoluteString == "http://www.hbo.com/game-of-thrones/index.html")
            #expect(show.status == "returning series")
            #expect(show.language == "en")
            #expect(show.availableTranslations?.count == 18)
            #expect(show.genres! == ["drama", "fantasy"])
            #expect(show.airedEpisodes == 50)
        }

        @Test func getShowImages() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones?extended=images", result: .success(jsonData(named: "Show_Images")))

            let show = try await traktManager.show(id: "game-of-thrones").summary().extend(.images).perform()
            #expect(show.title == "Severance")
            #expect(show.year == 2022)
            #expect(show.ids.trakt == 154997)
            #expect(show.ids.slug == "severance")
            #expect(show.images != nil)
            #expect(show.images?.poster.count == 1)
            #expect(show.overview == nil)
            #expect(show.firstAired == nil)
            #expect(show.airs == nil)
            #expect(show.runtime == nil)
            #expect(show.certification == nil)
            #expect(show.network == nil)
            #expect(show.country == nil)
            #expect(show.trailer == nil)
            #expect(show.homepage == nil)
            #expect(show.status == nil)
            #expect(show.rating == nil)
            #expect(show.votes == nil)
            #expect(show.updatedAt == nil)
            #expect(show.language == nil)
            #expect(show.availableTranslations == nil)
            #expect(show.genres == nil)
            #expect(show.airedEpisodes == nil)
        }

        // MARK: - Aliases

        @Test func getShowAliasesAwait() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/aliases", result: .success(jsonData(named: "ShowAliases")))

            let aliases = try await traktManager.show(id: "game-of-thrones").aliases().perform()
            #expect(aliases.count == 32)
        }

        // MARK: - Translations

        @Test func getShowTranslations() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/translations/es", result: .success(jsonData(named: "test_get_show_translations")))

            let translations = try await traktManager.show(id: "game-of-thrones")
                .translations(language: "es")
                .perform()

            #expect(translations.count == 40)
        }

        // MARK: - Comments

        @Test func getShowCommentsAsync() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/presumed-innocent/comments/newest", result: .success(jsonData(named: "test_get_show_comments")), headers: [.page(1), .pageCount(4)])

            let pagedObject = try await traktManager.show(id: "presumed-innocent")
                .comments(sort: "newest")
                .perform()
            let (watchedShows, page, total) = (pagedObject.object, pagedObject.currentPage, pagedObject.pageCount)

            #expect(watchedShows.count == 10)
            #expect(page == 1)
            #expect(total == 4)

            guard let firstComment = watchedShows.first else {
                Issue.record("No comments found")
                return
            }
            #expect(firstComment.comment == "I did NOT expect that ending. Wow! What a show!")
            #expect(firstComment.parentId == 0)
        }

        // MARK: - Lists

        @Test func getListsContainingShow() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/lists", result: .success(jsonData(named: "test_get_lists_containing_show")))

            let lists = try await traktManager.show(id: "game-of-thrones")
                .containingLists()
                .perform()

            #expect(lists.object.count == 1)
        }

        // MARK: - Collection Progress

        @Test func parseShowCollectionProgress() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/progress/collection?hidden=false&specials=false", result: .success(jsonData(named: "ShowCollectionProgress")))

            let collectionProgress = try await traktManager.show(id: "game-of-thrones")
                .collectedProgress(includeHiddenSeasons: false, includeSpecials: false)
                .perform()

            #expect(collectionProgress.aired == 8)
            #expect(collectionProgress.completed == 6)
            #expect(collectionProgress.seasons.count == 1)

            let season = collectionProgress.seasons[0]
            #expect(season.number == 1)
            #expect(season.aired == 8)
            #expect(season.completed == 6)
        }

        // MARK: - Watched Progress

        @Test func getWatchedProgress() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/progress/watched?hidden=false&specials=false", result: .success(jsonData(named: "test_get_wathced_progress")))

            let progress = try await traktManager.show(id: "game-of-thrones")
                .watchedProgress(includeHiddenSeasons: false, includeSpecials: false)
                .perform()

            #expect(progress.completed == 6)
            #expect(progress.aired == 8)
        }

        // MARK: - People

        @Test func getShowPeopleMin() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/people?extended=min", result: .success(jsonData(named: "ShowCastAndCrew_Min")))

            let castAndCrew = try await traktManager.show(id: "game-of-thrones")
                .people()
                .extend(.Min)
                .perform()

            #expect(castAndCrew.cast != nil)
            #expect(castAndCrew.producers != nil)
            #expect(castAndCrew.cast!.count == 43)
            #expect(castAndCrew.producers!.count == 24)

            guard let actor = castAndCrew.cast?.first else {
                Issue.record("Cast is empty")
                return
            }
            #expect(actor.person.name == "Emilia Clarke")
            #expect(actor.characters == ["Daenerys Targaryen"])
        }

        @Test func getShowPeopleFull() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/people?extended=full", result: .success(jsonData(named: "ShowCastAndCrew_Full")))

            let castAndCrew = try await traktManager.show(id: "game-of-thrones")
                .people()
                .extend(.Full)
                .perform()

            #expect(castAndCrew.cast != nil)
            #expect(castAndCrew.producers != nil)
            #expect(castAndCrew.cast!.count == 43)
            #expect(castAndCrew.producers!.count == 24)
        }

        @Test func getShowPeopleGuestStars() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/people?extended=guest_stars", result: .success(jsonData(named: "ShowCastAndCrew_GuestStars")), replace: true)

            let castAndCrew = try await traktManager.show(id: "game-of-thrones")
                .people()
                .extend(.guestStars)
                .perform()

            #expect(castAndCrew.cast != nil)
            #expect(castAndCrew.guestStars != nil)
            #expect(castAndCrew.producers != nil)
            #expect(castAndCrew.cast!.count == 3)
            #expect(castAndCrew.producers!.count == 2)
            #expect(castAndCrew.guestStars!.count == 3)
        }

        // MARK: - Ratings

        @Test func getShowRatings() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/ratings", result: .success(jsonData(named: "test_get_show_ratings")))

            let ratings = try await traktManager.show(id: "game-of-thrones")
                .ratings()
                .perform()

            #expect(ratings.rating == 9.38363)
            #expect(ratings.votes == 51065)
        }

        // MARK: - Related

        @Test func getRelatedShows() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/related?extended=min", result: .success(jsonData(named: "test_get_related_shows")))

            let relatedShows = try await traktManager.show(id: "game-of-thrones")
                .relatedShows()
                .extend(.Min)
                .perform()
                .object

            #expect(relatedShows.count == 10)
        }

        // MARK: - Stats

        @Test func getStats() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/stats", result: .success(jsonData(named: "ShowStats")))

            let stats = try await traktManager.show(id: "game-of-thrones")
                .stats()
                .perform()

            #expect(stats.comments == 298)
            #expect(stats.lists == 221719)
            #expect(stats.votes == 72920)
            #expect(stats.collectors == 710781)
            #expect(stats.collectedEpisodes == 36532224)
            #expect(stats.watchers == 610988)
        }

        // MARK: - Watching

        @Test func getUsersWatchingShow() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/watching", result: .success(jsonData(named: "test_get_users_watching_show")))

            let users = try await traktManager.show(id: "game-of-thrones")
                .usersWatching()
                .perform()

            #expect(users.count == 2)
        }

        // MARK: - Next episode

        @Test func getNextEpisode() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/next_episode?extended=min", result: .success(Data()), httpCode: 204)

            await #expect(throws: (any Error).self) {
                try await traktManager.show(id: "game-of-thrones")
                    .nextEpisode()
                    .extend(.Min)
                    .perform()
            }
        }

        // MARK: - Last episode

        @Test func getLastEpisode() async throws {
            try mock(.GET, "https://api.trakt.tv/shows/game-of-thrones/last_episode?extended=min", result: .success(jsonData(named: "LastEpisodeAired_min")))

            let episode = try await traktManager.show(id: "game-of-thrones")
                .lastEpisode()
                .extend(.Min)
                .perform()

            #expect(episode.title == "The Dragon and the Wolf")
            #expect(episode.season == 7)
            #expect(episode.number == 7)
        }

    }
}
