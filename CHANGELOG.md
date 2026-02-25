# Changelog

All notable changes to TraktKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2026-02-25

### Changed
- **BREAKING**: Renamed `TraktSpecificError` to `TraktAPIError` for improved clarity
- **BREAKING**: Renamed `TraktKitError` to `TraktClientError` for better distinction between client and API errors

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
