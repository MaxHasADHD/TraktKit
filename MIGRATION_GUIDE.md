# TraktKit 2.0 Migration Guide

## Overview

TraktKit 2.0 introduces a modern async/await API built on the new `Route` pattern, replacing the legacy completion handler-based API. This guide will help you migrate your code to the new architecture.

## Key Changes

### 1. Async/Await Instead of Completion Handlers

**Before (v1.x):**
```swift
traktManager.getTrendingMovies(page: 1, limit: 10) { result in
    switch result {
    case .success(let movies):
        print("Got \(movies.count) movies")
    case .error(let error):
        print("Error: \(error)")
    }
}
```

**After (v2.0):**
```swift
do {
    let result = try await traktManager.movies.trending()
        .page(1)
        .limit(10)
        .perform()
    print("Got \(result.object.count) movies")
} catch {
    print("Error: \(error)")
}
```

### 2. Route-Based API Pattern

All endpoints now return a `Route<T>` that you build with chainable methods:

```swift
// Build the route
let route = traktManager.movies.trending()
    .page(1)
    .limit(20)
    .extend(.full)

// Execute it
let result = try await route.perform()
```

### 3. Resource-Based Organization

Endpoints are now organized by resource type:

**Before:**
```swift
traktManager.getTrendingMovies(...)
traktManager.getTrendingShows(...)
traktManager.getMovie(movieID: ...)
```

**After:**
```swift
traktManager.movies.trending()
traktManager.shows.trending()
traktManager.movies.summary(movieId: ...)
```

## Common Migration Patterns

### Movies

#### Get Trending Movies
```swift
// Old
traktManager.getTrendingMovies(page: 1, limit: 10) { result in
    // handle result
}

// New
let result = try await traktManager.movies.trending()
    .page(1)
    .limit(10)
    .perform()
```

#### Get Movie Details
```swift
// Old
traktManager.getMovieDetails(movieID: "tron-legacy-2010") { result in
    // handle result
}

// New
let movie = try await traktManager.movies.summary(movieId: "tron-legacy-2010")
    .extend(.full)
    .perform()
```

### Shows

#### Get Trending Shows
```swift
// Old
traktManager.getTrendingShows(page: 1, limit: 10) { result in
    // handle result
}

// New
let result = try await traktManager.shows.trending()
    .page(1)
    .limit(10)
    .perform()
```

#### Get Show Details
```swift
// Old
traktManager.getShowDetails(showID: "game-of-thrones") { result in
    // handle result
}

// New
let show = try await traktManager.shows.summary(showId: "game-of-thrones")
    .extend(.full)
    .perform()
```

### Search

```swift
// Old
traktManager.search(query: "tron", types: [.movie], completion: { result in
    // handle result
})

// New
let results = try await traktManager.search.query(query: "tron")
    .type(.movie)
    .perform()
```

### User Data (Authentication Required)

#### Get Watched History
```swift
// Old
traktManager.getWatchedMovies { result in
    // handle result
}

// New
let watched = try await traktManager.users.watchedMovies(userId: "me")
    .perform()
```

#### Add to Watchlist
```swift
// Old
let movie = PostMovie(title: "Tron", ids: MovieIds(trakt: 12345))
traktManager.addMoviesToWatchlist(movies: [movie]) { result in
    // handle result
}

// New
let movie = PostMovie(title: "Tron", ids: MovieIds(trakt: 12345))
let result = try await traktManager.sync.addToWatchlist(movies: [movie])
    .perform()
```

## Pagination

### Fetching Paginated Results

**Single Page:**
```swift
let page1 = try await traktManager.movies.trending()
    .page(1)
    .limit(20)
    .perform()

print("Page \(page1.currentPage) of \(page1.pageCount)")
print("Items: \(page1.object)")
```

**All Pages (Concurrent):**
```swift
let allMovies: Set<TraktTrendingMovie> = try await traktManager.movies.trending()
    .limit(20)
    .fetchAllPages()

print("Got \(allMovies.count) total movies")
```

**Streaming Pages:**
```swift
for try await page in traktManager.movies.trending().pagedResults() {
    print("Processing page with \(page.count) items")
    // Process each page as it arrives
}
```

## Error Handling

Errors are now thrown instead of returned in completion handlers:

```swift
do {
    let movies = try await traktManager.movies.trending().perform()
    // Success
} catch TraktError.unauthorized {
    // User not authenticated
} catch TraktError.rateLimitExceeded {
    // Rate limit hit
} catch {
    // Other errors
}
```

### Common TraktError Cases

- `.unauthorized` - OAuth token missing or invalid
- `.forbidden` - Invalid API key
- `.noRecordFound` - 404 Not Found
- `.rateLimitExceeded` - Hit rate limit
- `.retry(after: TimeInterval)` - Retry after delay

## Extended Info

The `extended` parameter now uses a chainable method:

```swift
// Old
traktManager.getMovie(movieID: "tron", extended: [.Full, .Images]) { ... }

// New
let movie = try await traktManager.movies.summary(movieId: "tron")
    .extend(.full, .images)
    .perform()
```

## Using in SwiftUI

### With Task
```swift
struct MoviesView: View {
    @State private var movies: [TraktTrendingMovie] = []

    var body: some View {
        List(movies, id: \.movie.ids.trakt) { item in
            Text(item.movie.title ?? "")
        }
        .task {
            do {
                let result = try await traktManager.movies.trending()
                    .page(1)
                    .perform()
                movies = result.object
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

### With @State and Button
```swift
struct SearchView: View {
    @State private var searchResults: [TraktSearchResult] = []

    var body: some View {
        Button("Search") {
            Task {
                do {
                    searchResults = try await traktManager.search
                        .query(query: "tron")
                        .perform()
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}
```

## Authentication

### OAuth Flow (Unchanged)

The OAuth flow remains the same, but uses async/await:

```swift
// 1. Get auth URL (unchanged)
let authURL = traktManager.oauthURL

// 2. Exchange code for token
do {
    let authInfo = try await traktManager.getToken(authorizationCode: code)
    print("Authenticated!")
} catch {
    print("Auth failed: \(error)")
}
```

### Device Code Flow
```swift
// 1. Get device code
let deviceCode = try await traktManager.getAppCode()
print("Visit: \(deviceCode.verificationURL)")
print("Enter code: \(deviceCode.userCode)")

// 2. Poll for authorization
try await traktManager.pollForAccessToken(deviceCode: deviceCode)
print("Authenticated!")
```

## Breaking Changes Summary

### Removed
- ❌ All completion handler-based methods
- ❌ `URLSessionDataTask?` return types
- ❌ `ObjectResultType`, `ObjectsResultTypePagination` result types

### Changed
- ✅ All methods now return `Route<T>` or throw errors
- ✅ Methods organized by resource (`.movies`, `.shows`, `.users`, etc.)
- ✅ Async/await required (minimum iOS 16+)

### Added
- ✅ Route-based API with chainable methods
- ✅ Pagination helpers: `fetchAllPages()`, `pagedResults()`
- ✅ Structured concurrency support
- ✅ Built on SwiftAPIClient framework

## Minimum Requirements

- **iOS 16.0+** / tvOS 16.0+ / watchOS 9.0+ / macOS 14.0+
- **Swift 6.0+**
- **Xcode 15.0+**

## Step-by-Step Migration

1. **Update TraktKit dependency** to 2.0.0
2. **Fix compiler errors** by converting completion handlers to async/await
3. **Wrap calls in `Task {}`** if not already in async context
4. **Update error handling** from switch statements to try/catch
5. **Test thoroughly** - behavior should be identical

## Need Help?

- 📖 [Full API Documentation](https://github.com/MaxHasADHD/TraktKit)
- 🐛 [Report Issues](https://github.com/MaxHasADHD/TraktKit/issues)
- 💬 [Discussions](https://github.com/MaxHasADHD/TraktKit/discussions)

## Example: Complete Before & After

### Before (v1.x)
```swift
class MovieViewModel {
    var movies: [TraktTrendingMovie] = []

    func loadMovies() {
        traktManager.getTrendingMovies(page: 1, limit: 20) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies
                case .error(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
}
```

### After (v2.0)
```swift
@MainActor
class MovieViewModel: ObservableObject {
    @Published var movies: [TraktTrendingMovie] = []

    func loadMovies() async {
        do {
            let result = try await traktManager.movies.trending()
                .page(1)
                .limit(20)
                .perform()
            movies = result.object
        } catch {
            print("Error: \(error)")
        }
    }
}
```

---

**Ready to migrate?** Start with a small, non-critical endpoint to get familiar with the new pattern, then gradually migrate the rest of your codebase. The new API is more concise, safer, and easier to test!
