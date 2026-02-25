# TraktKit Migration Guides

This document serves as an index to all migration guides for TraktKit version upgrades.

## Available Migration Guides

### [v3.1.x to v3.2.0](migrations/v3.1-to-v3.2.md)
**Error Type Renames**

Improves error type naming for better clarity and consistency:
- `TraktSpecificError` → `TraktAPIError`
- `TraktKitError` → `TraktClientError`

Quick migration with find & replace. Compiler errors will guide you.

---

### [v1.x to v2.0](migrations/v1-to-v2.md)
**Async/Await Migration and API Restructure**

Major rewrite introducing modern async/await API:
- Completion handlers replaced with async/await
- Resource-based API organization (`.movies`, `.shows`, `.users`)
- Route-based pattern with chainable methods
- Minimum iOS 16+, Swift 6.0 required

Comprehensive guide with before/after examples for all common patterns.

---

## Quick Links

- [**CHANGELOG**](../CHANGELOG.md) - Summary of all changes across versions
- [**README**](../README.md) - Getting started guide
- [**Migrations Directory**](migrations/) - All detailed migration guides

## How to Use These Guides

1. **Check your current version** - Run `swift package show-dependencies` or check your `Package.swift`
2. **Find your migration path** - Select the guide(s) that cover your version upgrade
3. **Read the CHANGELOG** - Get a quick overview of what changed
4. **Follow the migration guide** - Detailed steps with code examples
5. **Test incrementally** - Update and test as you go

## Version History

| Version | Release Date | Major Changes |
|---------|--------------|---------------|
| **3.2.0** | 2026-02-25 | Error type renames |
| **3.1.1** | 2026-02-24 | Bug fixes |
| **3.1.0** | 2026-02-22 | PKCE authentication support |
| **3.0.0** | 2026-02-21 | Removed completion handlers |
| **2.0.0** | 2026-02-21 | Async/await API, major rewrite |
| **1.5.7** | Earlier | Legacy completion handler API |

## Need Help?

- 📖 [API Documentation](https://github.com/MaxHasADHD/TraktKit)
- 🐛 [Report Issues](https://github.com/MaxHasADHD/TraktKit/issues)

## Contributing

Found an issue or have suggestions? [Open an issue](https://github.com/MaxHasADHD/TraktKit/issues) or submit a pull request!
