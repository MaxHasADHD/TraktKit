//
//  SharedTypesTests.swift
//  TraktKit
//
//  Created by Claude Code on 2/26/26.
//

import Foundation
import Testing
@testable import TraktKit

@Suite
struct SharedTypesTests {
    
    // MARK: - LookupType Tests
    
    @Test
    func lookupTypeTrakt() {
        let lookup = LookupType.Trakt(id: 12345)
        
        #expect(lookup.name == "trakt")
        #expect(lookup.id == "12345")
    }
    
    @Test
    func lookupTypeIMDB() {
        let lookup = LookupType.IMDB(id: "tt0133093")
        
        #expect(lookup.name == "imdb")
        #expect(lookup.id == "tt0133093")
    }
    
    @Test
    func lookupTypeTMDB() {
        let lookup = LookupType.TMDB(id: 603)
        
        #expect(lookup.name == "tmdb")
        #expect(lookup.id == "603")
    }
    
    @Test
    func lookupTypeTVDB() {
        let lookup = LookupType.TVDB(id: 121361)
        
        #expect(lookup.name == "tvdb")
        #expect(lookup.id == "121361")
    }
    
    @Test
    func lookupTypeTVRage() {
        let lookup = LookupType.TVRage(id: 3908)
        
        #expect(lookup.name == "tvrage")
        #expect(lookup.id == "3908")
    }
    
    // MARK: - SearchType Tests
    
    @Test
    func searchTypeMovie() {
        let searchType = SearchType.movie
        
        #expect(searchType.rawValue == "movie")
    }
    
    @Test
    func searchTypeShow() {
        let searchType = SearchType.show
        
        #expect(searchType.rawValue == "show")
    }
    
    @Test
    func searchTypeEpisode() {
        let searchType = SearchType.episode
        
        #expect(searchType.rawValue == "episode")
    }
    
    @Test
    func searchTypePerson() {
        let searchType = SearchType.person
        
        #expect(searchType.rawValue == "person")
    }
    
    @Test
    func searchTypeList() {
        let searchType = SearchType.list
        
        #expect(searchType.rawValue == "list")
    }
    
    // MARK: - MediaType Tests
    
    @Test
    func mediaTypeMovies() {
        let mediaType = MediaType.movies
        
        #expect(mediaType.rawValue == "movies")
        #expect(mediaType.description == "movies")
    }
    
    @Test
    func mediaTypeShows() {
        let mediaType = MediaType.shows
        
        #expect(mediaType.rawValue == "shows")
        #expect(mediaType.description == "shows")
    }
    
    // MARK: - WatchedType Tests
    
    @Test
    func watchedTypeMovies() {
        let type = WatchedType.Movies
        
        #expect(type.rawValue == "movies")
        #expect(type.description == "movies")
    }
    
    @Test
    func watchedTypeShows() {
        let type = WatchedType.Shows
        
        #expect(type.rawValue == "shows")
        #expect(type.description == "shows")
    }
    
    @Test
    func watchedTypeSeasons() {
        let type = WatchedType.Seasons
        
        #expect(type.rawValue == "seasons")
        #expect(type.description == "seasons")
    }
    
    @Test
    func watchedTypeEpisodes() {
        let type = WatchedType.Episodes
        
        #expect(type.rawValue == "episodes")
        #expect(type.description == "episodes")
    }
    
    // MARK: - Type2 Tests
    
    @Test
    func type2All() {
        let type = Type2.All
        
        #expect(type.rawValue == "all")
        #expect(type.description == "all")
    }
    
    @Test
    func type2Movies() {
        let type = Type2.Movies
        
        #expect(type.rawValue == "movies")
        #expect(type.description == "movies")
    }
    
    @Test
    func type2Shows() {
        let type = Type2.Shows
        
        #expect(type.rawValue == "shows")
        #expect(type.description == "shows")
    }
    
    @Test
    func type2Seasons() {
        let type = Type2.Seasons
        
        #expect(type.rawValue == "seasons")
        #expect(type.description == "seasons")
    }
    
    @Test
    func type2Episodes() {
        let type = Type2.Episodes
        
        #expect(type.rawValue == "episodes")
        #expect(type.description == "episodes")
    }
    
    @Test
    func type2Lists() {
        let type = Type2.Lists
        
        #expect(type.rawValue == "lists")
        #expect(type.description == "lists")
    }
    
    // MARK: - ListType Tests
    
    @Test
    func listTypeAll() {
        let type = ListType.all
        
        #expect(type.rawValue == "all")
        #expect(type.description == "all")
    }
    
    @Test
    func listTypePersonal() {
        let type = ListType.personal
        
        #expect(type.rawValue == "personal")
        #expect(type.description == "personal")
    }
    
    @Test
    func listTypeOfficial() {
        let type = ListType.official
        
        #expect(type.rawValue == "official")
        #expect(type.description == "official")
    }
    
    @Test
    func listTypeWatchlists() {
        let type = ListType.watchlists
        
        #expect(type.rawValue == "watchlists")
        #expect(type.description == "watchlists")
    }
    
    // MARK: - ListSortType Tests
    
    @Test
    func listSortTypePopular() {
        let type = ListSortType.popular
        
        #expect(type.rawValue == "popular")
        #expect(type.description == "popular")
    }
    
    @Test
    func listSortTypeLikes() {
        let type = ListSortType.likes
        
        #expect(type.rawValue == "likes")
        #expect(type.description == "likes")
    }
    
    @Test
    func listSortTypeComments() {
        let type = ListSortType.comments
        
        #expect(type.rawValue == "comments")
        #expect(type.description == "comments")
    }
    
    @Test
    func listSortTypeItems() {
        let type = ListSortType.items
        
        #expect(type.rawValue == "items")
        #expect(type.description == "items")
    }
    
    @Test
    func listSortTypeAdded() {
        let type = ListSortType.added
        
        #expect(type.rawValue == "added")
        #expect(type.description == "added")
    }
    
    @Test
    func listSortTypeUpdated() {
        let type = ListSortType.updated
        
        #expect(type.rawValue == "updated")
        #expect(type.description == "updated")
    }
    
    // MARK: - CommentType Tests
    
    @Test
    func commentTypeAll() {
        let type = CommentType.all
        
        #expect(type.rawValue == "all")
    }
    
    @Test
    func commentTypeReviews() {
        let type = CommentType.reviews
        
        #expect(type.rawValue == "reviews")
    }
    
    @Test
    func commentTypeShouts() {
        let type = CommentType.shouts
        
        #expect(type.rawValue == "shouts")
    }
    
    // MARK: - ExtendedType Tests
    
    @Test
    func extendedTypeMin() {
        let type = ExtendedType.Min
        
        #expect(type.rawValue == "min")
        #expect(type.description == "min")
    }
    
    @Test
    func extendedTypeFull() {
        let type = ExtendedType.Full
        
        #expect(type.rawValue == "full")
        #expect(type.description == "full")
    }
    
    @Test
    func extendedTypeMetadata() {
        let type = ExtendedType.Metadata
        
        #expect(type.rawValue == "metadata")
        #expect(type.description == "metadata")
    }
    
    @Test
    func extendedTypeEpisodes() {
        let type = ExtendedType.Episodes
        
        #expect(type.rawValue == "episodes")
        #expect(type.description == "episodes")
    }
    
    @Test
    func extendedTypeNoSeasons() {
        let type = ExtendedType.noSeasons
        
        #expect(type.rawValue == "noseasons")
        #expect(type.description == "noseasons")
    }
    
    @Test
    func extendedTypeGuestStars() {
        let type = ExtendedType.guestStars
        
        #expect(type.rawValue == "guest_stars")
        #expect(type.description == "guest_stars")
    }
    
    @Test
    func extendedTypeImages() {
        let type = ExtendedType.images
        
        #expect(type.rawValue == "images")
        #expect(type.description == "images")
    }
    
    // MARK: - ListItemType Tests
    
    @Test
    func listItemTypeMovies() {
        let type = ListItemType.movies
        
        #expect(type.rawValue == "movie")
    }
    
    @Test
    func listItemTypeShows() {
        let type = ListItemType.shows
        
        #expect(type.rawValue == "show")
    }
    
    @Test
    func listItemTypeSeasons() {
        let type = ListItemType.seasons
        
        #expect(type.rawValue == "season")
    }
    
    @Test
    func listItemTypeEpisodes() {
        let type = ListItemType.episodes
        
        #expect(type.rawValue == "episode")
    }
    
    @Test
    func listItemTypePeople() {
        let type = ListItemType.people
        
        #expect(type.rawValue == "person")
    }
    
    // MARK: - Period Tests
    
    @Test
    func periodDaily() {
        let period = Period.daily
        
        #expect(period.rawValue == "daily")
        #expect(period.description == "daily")
    }
    
    @Test
    func periodWeekly() {
        let period = Period.weekly
        
        #expect(period.rawValue == "weekly")
        #expect(period.description == "weekly")
    }
    
    @Test
    func periodMonthly() {
        let period = Period.monthly
        
        #expect(period.rawValue == "monthly")
        #expect(period.description == "monthly")
    }
    
    @Test
    func periodYearly() {
        let period = Period.yearly
        
        #expect(period.rawValue == "yearly")
        #expect(period.description == "yearly")
    }
    
    @Test
    func periodAll() {
        let period = Period.all
        
        #expect(period.rawValue == "all")
        #expect(period.description == "all")
    }
    
    // MARK: - HiddenItemsType Tests
    
    @Test
    func hiddenItemsTypeMovie() {
        let type = HiddenItemsType.Movie
        
        #expect(type.rawValue == "movie")
    }
    
    @Test
    func hiddenItemsTypeShow() {
        let type = HiddenItemsType.Show
        
        #expect(type.rawValue == "show")
    }
    
    @Test
    func hiddenItemsTypeSeason() {
        let type = HiddenItemsType.Season
        
        #expect(type.rawValue == "Season")
    }
    
    // MARK: - LikeType Tests
    
    @Test
    func likeTypeComments() {
        let type = LikeType.Comments
        
        #expect(type.rawValue == "comments")
    }
    
    @Test
    func likeTypeLists() {
        let type = LikeType.Lists
        
        #expect(type.rawValue == "lists")
    }
    
    // MARK: - Sequence Extension Tests

    @Test
    func queryStringPeriods() {
        let periods: [Period] = [.weekly, .monthly]
        let queryString = periods.queryString()

        #expect(queryString == "weekly,monthly")
    }

    @Test
    func queryStringExtendedTypes() {
        let types: [ExtendedType] = [.Full, .images]
        let queryString = types.queryString()

        #expect(queryString == "full,images")
    }

    @Test
    func queryStringSingleItem() {
        let types: [MediaType] = [.movies]
        let queryString = types.queryString()

        #expect(queryString == "movies")
    }

    @Test
    func queryStringEmptyArray() {
        let types: [MediaType] = []
        let queryString = types.queryString()

        #expect(queryString == "")
    }
}
