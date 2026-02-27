//
//  FiltersTests.swift
//  TraktKit
//
//  Created by Claude Code on 2/26/26.
//

import Foundation
import Testing
@testable import TraktKit

@Suite
struct FiltersTests {
    
    // MARK: - Filter Tests
    
    @Test
    func filterYear() {
        let filter = TraktManager.Filter.year(year: 2024)
        let (key, value) = filter.value()
        
        #expect(key == "years")
        #expect(value == "2024")
    }
    
    @Test
    func filterGenresSingle() {
        let filter = TraktManager.Filter.genres(genres: ["action"])
        let (key, value) = filter.value()
        
        #expect(key == "genres")
        #expect(value == "action")
    }
    
    @Test
    func filterGenresMultiple() {
        let filter = TraktManager.Filter.genres(genres: ["action", "adventure", "comedy"])
        let (key, value) = filter.value()
        
        #expect(key == "genres")
        #expect(value == "action,adventure,comedy")
    }
    
    @Test
    func filterLanguagesSingle() {
        let filter = TraktManager.Filter.languages(languages: ["en"])
        let (key, value) = filter.value()
        
        #expect(key == "languages")
        #expect(value == "en")
    }
    
    @Test
    func filterLanguagesMultiple() {
        let filter = TraktManager.Filter.languages(languages: ["en", "fr", "es"])
        let (key, value) = filter.value()
        
        #expect(key == "languages")
        #expect(value == "en,fr,es")
    }
    
    @Test
    func filterCountriesSingle() {
        let filter = TraktManager.Filter.countries(countries: ["us"])
        let (key, value) = filter.value()
        
        #expect(key == "countries")
        #expect(value == "us")
    }
    
    @Test
    func filterCountriesMultiple() {
        let filter = TraktManager.Filter.countries(countries: ["us", "ca", "gb"])
        let (key, value) = filter.value()
        
        #expect(key == "countries")
        #expect(value == "us,ca,gb")
    }
    
    @Test
    func filterRuntimes() {
        let filter = TraktManager.Filter.runtimes(runtimes: (lower: 90, upper: 120))
        let (key, value) = filter.value()
        
        #expect(key == "runtimes")
        #expect(value == "90-120")
    }
    
    @Test
    func filterRatings() {
        let filter = TraktManager.Filter.ratings(ratings: (lower: 70, upper: 100))
        let (key, value) = filter.value()
        
        #expect(key == "ratings")
        #expect(value == "70-100")
    }
    
    @Test
    func filterRatingsMinimum() {
        let filter = TraktManager.Filter.ratings(ratings: (lower: 0, upper: 100))
        let (key, value) = filter.value()
        
        #expect(key == "ratings")
        #expect(value == "0-100")
    }
    
    // MARK: - MovieFilter Tests
    
    @Test
    func movieFilterCertificationsSingle() {
        let filter = TraktManager.MovieFilter.certifications(certifications: ["PG-13"])
        let (key, value) = filter.value()
        
        #expect(key == "genres")
        #expect(value == "PG-13")
    }
    
    @Test
    func movieFilterCertificationsMultiple() {
        let filter = TraktManager.MovieFilter.certifications(certifications: ["PG", "PG-13", "R"])
        let (key, value) = filter.value()
        
        #expect(key == "genres")
        #expect(value == "PG,PG-13,R")
    }
    
    // MARK: - ShowFilter Tests
    
    @Test
    func showFilterCertificationsSingle() {
        let filter = TraktManager.ShowFilter.certifications(certifications: ["TV-14"])
        let (key, value) = filter.value()
        
        #expect(key == "genres")
        #expect(value == "TV-14")
    }
    
    @Test
    func showFilterCertificationsMultiple() {
        let filter = TraktManager.ShowFilter.certifications(certifications: ["TV-PG", "TV-14", "TV-MA"])
        let (key, value) = filter.value()
        
        #expect(key == "genres")
        #expect(value == "TV-PG,TV-14,TV-MA")
    }
    
    @Test
    func showFilterNetworksSingle() {
        let filter = TraktManager.ShowFilter.networks(networks: ["HBO"])
        let (key, value) = filter.value()
        
        #expect(key == "networks")
        #expect(value == "HBO")
    }
    
    @Test
    func showFilterNetworksMultiple() {
        let filter = TraktManager.ShowFilter.networks(networks: ["HBO", "Netflix", "Amazon"])
        let (key, value) = filter.value()
        
        #expect(key == "networks")
        #expect(value == "HBO,Netflix,Amazon")
    }
    
    @Test
    func showFilterStatusSingle() {
        let filter = TraktManager.ShowFilter.status(status: ["returning series"])
        let (key, value) = filter.value()
        
        #expect(key == "status")
        #expect(value == "returning series")
    }
    
    @Test
    func showFilterStatusMultiple() {
        let filter = TraktManager.ShowFilter.status(status: ["returning series", "in production", "ended"])
        let (key, value) = filter.value()
        
        #expect(key == "status")
        #expect(value == "returning series,in production,ended")
    }
    
    // MARK: - Edge Cases
    
    @Test
    func filterGenresEmpty() {
        let filter = TraktManager.Filter.genres(genres: [])
        let (key, value) = filter.value()
        
        #expect(key == "genres")
        #expect(value == "")
    }
    
    @Test
    func filterLanguagesEmpty() {
        let filter = TraktManager.Filter.languages(languages: [])
        let (key, value) = filter.value()
        
        #expect(key == "languages")
        #expect(value == "")
    }
    
    @Test
    func filterCountriesEmpty() {
        let filter = TraktManager.Filter.countries(countries: [])
        let (key, value) = filter.value()
        
        #expect(key == "countries")
        #expect(value == "")
    }
    
    @Test
    func filterRuntimesZeroRange() {
        let filter = TraktManager.Filter.runtimes(runtimes: (lower: 0, upper: 0))
        let (key, value) = filter.value()
        
        #expect(key == "runtimes")
        #expect(value == "0-0")
    }
    
    @Test
    func filterYearVeryOld() {
        let filter = TraktManager.Filter.year(year: 1900)
        let (key, value) = filter.value()
        
        #expect(key == "years")
        #expect(value == "1900")
    }
    
    @Test
    func filterYearFuture() {
        let filter = TraktManager.Filter.year(year: 2050)
        let (key, value) = filter.value()
        
        #expect(key == "years")
        #expect(value == "2050")
    }
}
