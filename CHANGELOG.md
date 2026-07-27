# Changelog

All notable changes to TraktKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.9.0] - 2026-07-27

### Added
- `TraktList.user` — the list's owner, returned by every list-reading endpoint (search,
  trending, popular, a user's lists, list summary). Optional defensively for write-style
  responses. Callers that previously decoded `/search/list` with a custom type just to reach
  the owner can now use `TraktSearchResult.list?.user` directly.

### Changed
- **BREAKING**: `User.IDs.slug` is now `String?`, matching Trakt's own data: the placeholder
  account that owns Trakt's *official* lists (`"type": "official"`) has
  `"ids": {"slug": null, "trakt": 0}`. The field will be populated for real users; treat a
  missing slug as "not addressable by username" (official lists can only be addressed by list
  id, never as `users/{slug}/lists/{list}`). Without this, one official list in a response —
  they appear throughout list search/trending/popular — failed the entire page's decode.

## [3.7.0] - 2026-07-06

Updated to SwiftAPIClient 1.7.0, which reworks the auth lifecycle so that an
**expired token is now a signed-in state** rather than an error. This fixes a
class of bugs where authenticated users were forced to re-authenticate (e.g.
daily, once the 24-hour access token expired). See the
[v3.6 → v3.7 migration guide](docs/migrations/v3.6-to-v3.7.md) for details.

### Fixed
- Authenticated users could be pushed back through the sign-in flow after their access token expired. Previously, loading an expired token threw, so the cached auth state never populated and the user appeared signed-out even though a valid (single-use) refresh token was stored. Expired-but-authenticated is now a first-class signed-in state (`isSignedIn == true`) that refreshes on demand via the `AuthCoordinator`.
- Reinstall recovery: the Keychain survives an app reinstall but the UserDefaults expiration date does not. A missing expiration date is now treated as an expired state (`Date.distantPast`) that triggers a refresh, instead of throwing and signing the user out.

### Changed
- **BREAKING**: `Route.fetchAllPages()` now returns `PagedFetchResult<Element>` instead of `Set<Element>`. Access items via `.items`, and check `.isComplete` / `.failedPages` to detect partial fetches (a later-page failure now surfaces the partial data instead of being silently swallowed). A new `retryLimit:` parameter is forwarded to each page request — pass `0` to fail fast instead of sleeping through Trakt's rate-limit `retry-after`.
- **BREAKING**: `TraktManager.checkToRefresh()` is renamed to `refreshTokenIfNeeded()`. The behavior is the same — refresh the access token if it has expired — but the name reflects that it's only for authenticated flows and that non-authenticated requests work without it.
- **BREAKING**: Custom `TraktAuthentication` implementations must update `getCurrentState()`. It is now non-throwing and returns `AuthenticationState?` (`async -> AuthenticationState?`). Return whatever credentials exist — **even expired ones** — and return `nil` only when nothing is stored. Expiry is read from `AuthenticationState.isExpired`, not from an error.
- **BREAKING**: `AuthenticationError.tokenExpired(refreshToken:)` and `.noStoredCredentials` are removed (both were re-exported through TraktKit's `AuthenticationError` typealias). Expiry is now `AuthenticationState.isExpired`; missing credentials are a `nil` state. `.notConfigured` is the only remaining case.
- **BREAKING** (advanced): `TraktManager.mutableRequest(forPath:withQuery:isAuthorized:withHTTPMethod:body:)` is now `async` so it can await the coordinator's first storage load. Direct callers must add `await`.
- `KeychainTraktAuthentication` now returns expired credentials as state instead of throwing, and treats a missing expiration date as an expired state (`Date.distantPast`) rather than an error.
- Updated to SwiftAPIClient 1.7.0.

### Migration Guide
```swift
// fetchAllPages — Before (3.6.x): returned Set<Element>
let shows: Set<TraktWatchedShow> = try await traktManager.sync()
    .watchedShows()
    .limit(100)
    .fetchAllPages()

// fetchAllPages — After (3.7.0): returns PagedFetchResult<Element>
let result = try await traktManager.sync()
    .watchedShows()
    .limit(100)
    .fetchAllPages()
let shows: Set<TraktWatchedShow> = result.items
if !result.isComplete {
    // Some pages failed; inspect result.failedPages before treating items as complete.
}

// Refresh — Before
try await traktManager.checkToRefresh()
// Refresh — After
try await traktManager.refreshTokenIfNeeded()

// Catching auth errors — Before
do {
    try await traktManager.refreshTokenIfNeeded()
} catch AuthenticationError.tokenExpired {
    // ...refresh path
} catch AuthenticationError.noStoredCredentials {
    // ...show sign-in
}
// Catching auth errors — After: expiry is no longer an error.
// refreshTokenIfNeeded() refreshes an expired token internally and throws
// TraktClientError.userNotAuthorized only when no credentials are stored.
do {
    try await traktManager.refreshTokenIfNeeded()
} catch TraktClientError.userNotAuthorized {
    // ...show sign-in (genuinely no stored credentials)
}
```

## [3.6.1] - 2026-06-27

### Fixed
- Token refresh now consistently routes through the shared `AuthCoordinator`, so concurrent refreshes are coalesced into a single request. This avoids reusing Trakt's now single-use refresh tokens across siblings/instances that share a coordinator.

## [3.6.0] - 2026-06-21

### Added
- Filled in missing properties on `TraktShow`, `TraktEpisode`, and `TraktMovie` to match the fields Trakt returns.

## [3.5.0] - 2026-05-27

### Added
- `ExtendedType.progress` — sends `?extended=progress` on the watched endpoints. As of Trakt's May 2026 API change, `extended=full` no longer returns the `seasons` array on watched shows; combine `.extend(.Full, .progress)` to retain per-episode watched data.

### Changed
- **BREAKING**: The Trakt watched endpoints became paginated on May 30, 2026. Three route signatures changed accordingly:
  - `SyncResource.watchedShows()` → `Route<PagedObject<[TraktWatchedShow]>>` (was `Route<[TraktWatchedShow]>`)
  - `SyncResource.watchedMovies()` → `Route<PagedObject<[TraktWatchedMovie]>>` (was `Route<[TraktWatchedMovie]>`)
  - `UsersResource.watched(type:)` → `Route<PagedObject<[TraktWatchedItem]>>` (was `Route<[TraktWatchedItem]>`)

  Callers must now use `.fetchAllPages()` (or paginate explicitly) and access results via `.object`. Default page size is 100; max is 250. Trakt may serve fewer items than requested for `extended=progress` — `SwiftAPIClient.fetchAllPages` handles that automatically when both `X-Pagination-Limit` and `X-Pagination-Item-Count` are sent (which Trakt does).
- Updated to SwiftAPIClient 1.6.0.

### Migration Guide
```swift
// Before
let shows = try await traktManager.sync()
    .watchedShows()
    .extend(.Full)
    .perform()

// After — paginated + .progress for seasons array
let shows: Set<TraktWatchedShow> = try await traktManager.sync()
    .watchedShows()
    .extend(.Full, .progress)
    .limit(100)
    .fetchAllPages()

// Single-page access is still possible
let firstPage = try await traktManager.sync()
    .watchedShows()
    .extend(.Full, .progress)
    .limit(100)
    .page(1)
    .perform()
let shows = firstPage.object
print("Page \(firstPage.currentPage) of \(firstPage.pageCount) — \(firstPage.itemCount ?? 0) total")
```

See https://github.com/trakt/trakt-api/discussions/775 for the upstream announcement.

## [3.4.0] - 2026-05-26

### Added
- `TraktManager.init(..., sharedAuthCoordinator:)` — construct a sibling `TraktManager` that shares auth state and coalesces token refreshes with another manager. Useful when running a second `URLSession` against the same account (e.g., a dedicated session for background sync).

### Changed
- Updated to SwiftAPIClient 1.5.1. `TraktManager` now reads and writes credentials through the shared `AuthCoordinator` instead of holding its own storage reference. Internal change; no caller migration required.

## [3.3.2] - 2026-04-20

### Fixed
- `KeychainTraktAuthentication.updateState` was not updating its in-memory `expirationDate`. After a token refresh the cached expiration could drift from what was written to UserDefaults until the next process restart, causing proactive-refresh decisions to be made against a stale value.

### Changed
- Updated to SwiftAPIClient 1.4.1.

## [3.3.1] - 2026-04-16

### Changed
- Updated to SwiftAPIClient 1.4.0.
- Switched `Package.swift` to declare `swiftLanguageModes: [.v6]`.

## [3.3.0] - 2026-04-11

### Added
- **BREAKING**: `TraktManager.init` now requires a `userAgent` parameter. The value is sent as the `User-Agent` header on every request — Trakt asks API clients to identify themselves with something like `MyAppName/1.0.0`. Existing call sites will fail to compile until they supply the new argument.

## [3.2.1] - 2026-03-08

### Fixed
- Added missing `import Foundation` to several model files (`DeviceCode`, `OAuthBody`, `TraktFavoritedMovie`, `TraktFavoritedShow`, `WatchlistUpdate`) that were transitively relying on other imports.

## [3.2.0] - 2026-02-25

### Added
- **Automatic token refresh support** - Tokens are now automatically refreshed when they expire within 1 hour or when requests fail with 401 errors
  - Proactive refresh: Refreshes tokens before they expire (configurable threshold, default 1 hour)
  - Reactive refresh: Automatically refreshes and retries on 401 Unauthorized errors
  - Powered by SwiftAPIClient 1.3.0's `TokenRefreshHandler` protocol
  - No code changes required - works automatically when authenticated

### Changed
- **BREAKING**: Renamed `TraktSpecificError` to `TraktAPIError` for improved clarity
- **BREAKING**: Renamed `TraktKitError` to `TraktClientError` for better distinction between client and API errors
- Updated to SwiftAPIClient 1.3.2 for automatic token refresh support

### Fixed
- Fixed typo in internal `StatusCodes.accountLocked` constant (was `acountLocked`)

**Migration Guide**: See [v3.1.x to v3.2.0](docs/migrations/v3.1-to-v3.2.md) for migration instructions.

## [3.1.1] - 2026-02-24

### Fixed
- Fixed return type for `/notes/{id}/item` endpoint

## [3.1.0] - 2026-02-22

### Added
- Added PKCE (Proof Key for Code Exchange) support for OAuth authentication
- Added `oauthURL(codeChallenge:)` method for PKCE-based authorization
- Added `getToken(authorizationCode:codeVerifier:)` method for token exchange with PKCE

### Fixed
- Fixed `TraktNoteItem` missing note information

### Changed
- Updated example app with latest API usage patterns

## [3.0.0] - 2026-02-21

### Removed
- **BREAKING**: Removed all deprecated completion handler methods (use async/await instead)

### Changed
- Renamed and reorganized files for better consistency across the project

### Added
- Added endpoint paths to function documentation for easier API reference lookup

### Fixed
- Fixed User endpoint return types
- Updated unit tests to reflect API changes

**Migration Guide**: Completion handler methods were deprecated in 2.0.0. Use the async/await equivalents introduced in 2.0.0.

## [2.0.1] - 2026-02-21

### Fixed
- Updated User endpoint return types
- Fixed unit tests

## [2.0.0] - 2026-02-21

### Added
- **NEW**: Full async/await API for all endpoints
- **NEW**: Resource-based API organization (`.movies`, `.shows`, `.users`, `.sync`, etc.)
- **NEW**: Route-based pattern with chainable methods (`.page()`, `.limit()`, `.extend()`)
- **NEW**: Built on new `SwiftAPIClient` framework for better modularity
- **NEW**: Pagination helpers: `fetchAllPages()` and `pagedResults()` for AsyncSequence support
- **NEW**: Certification endpoints
- **NEW**: Recommendation endpoints
- **NEW**: Scrobble endpoints
- **NEW**: Note endpoints
- **NEW**: Enhanced Comments endpoints
- **NEW**: Network endpoint
- **NEW**: Language endpoints
- **NEW**: Genres endpoints
- **NEW**: Countries endpoints
- **NEW**: Calendar endpoints
- **NEW**: Expanded List endpoints
- **NEW**: People endpoints with crew headshots
- **NEW**: Episode screenshots support
- **NEW**: Trakt image API support
- **NEW**: Checkin resource
- **NEW**: Additional User endpoints for lists and watchlist management
- **NEW**: Additional Sync endpoints
- **NEW**: Migration guide for upgrading from 1.x

### Changed
- **BREAKING**: Minimum deployment targets updated to iOS 16.0+, tvOS 16.0+, watchOS 9.0+, macOS 14.0+
- **BREAKING**: Swift 6.0 now required
- **BREAKING**: All endpoint methods now return `Route<T>` instead of accepting completion handlers
- **BREAKING**: Result types changed from `ObjectResultType` to `PagedObject<T>`
- Improved authentication handling with refactored authentication class
- Enhanced testability with better API customization

### Deprecated
- All completion handler-based methods (removed in 3.0.0)

### Fixed
- Fixed decoding of account settings with optional values
- Fixed various model decoding issues

**Migration Guide**: See [v1.x to v2.0](docs/migrations/v1-to-v2.md) for detailed migration instructions.

## [1.5.7] and Earlier

Earlier versions did not maintain a detailed changelog. See [Git history](https://github.com/MaxHasADHD/TraktKit/commits/master) for changes in 1.x versions.

[3.2.0]: https://github.com/MaxHasADHD/TraktKit/compare/3.1.1...3.2.0
[3.1.1]: https://github.com/MaxHasADHD/TraktKit/compare/3.1.0...3.1.1
[3.1.0]: https://github.com/MaxHasADHD/TraktKit/compare/3.0.0...3.1.0
[3.0.0]: https://github.com/MaxHasADHD/TraktKit/compare/2.0.1...3.0.0
[2.0.1]: https://github.com/MaxHasADHD/TraktKit/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/MaxHasADHD/TraktKit/compare/1.5.7...2.0.0
[1.5.7]: https://github.com/MaxHasADHD/TraktKit/releases/tag/1.5.7
