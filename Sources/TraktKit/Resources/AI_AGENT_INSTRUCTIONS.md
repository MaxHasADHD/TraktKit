# TraktKit — AI Agent Instructions

## What this project is

TraktKit is a Swift wrapper for the [Trakt API](https://trakt.docs.apiary.io). The goal is to have a typed Swift function for every Trakt API endpoint, with documentation copied from the Trakt API docs. This file tells an AI agent how to add or update endpoints correctly and consistently.

---

## How to use this document

Paste the contents of this file into the system prompt or first message of your AI session. Then point the agent at the Trakt API documentation and tell it which group to work on.

---

## Step 0 — Ask which API group to work on

Before doing anything, ask the user:

> "Which group from the Trakt API document would you like me to implement or update?"

Wait for the answer. Do not proceed until the user names a specific group (e.g. *Calendars*, *Lists*, *People*).

---

## Step 1 — Read before writing

Read the following files **in full** before writing a single line of code. Do not skip any of them.

| File | Why |
|---|---|
| `Sources/TraktKit/Resources/TraktManager+Resources.swift` | Understand the accessor pattern and what already exists |
| `Sources/TraktKit/Resources/PeopleResource.swift` | Canonical example of Resource structure |
| `Sources/TraktKit/Resources/MoviesResource.swift` | Shows both a collection resource (`MoviesResource`) and a single-item resource (`MovieResource`) in the same file |
| `Sources/TraktKit/Resources/CalendarsResource.swift` | Shows the split `my/` vs `all/` pattern where applicable |

Then read the **Trakt API documentation** for the requested group in full before forming any plan.

---

## Step 2 — Check what already exists

Search the project for:

- A Resource file for this group (e.g. `ListsResource.swift`, `CalendarsResource.swift`)
- An accessor on `TraktManager` for this group (in `TraktManager+Resources.swift`)
- A test file in `Tests/TraktKitTests/ResourceTests/` (e.g. `ListsTests.swift`, `CalendarsTests.swift`)
- Existing Codable model types that match the response shapes in the API doc

Report what you find to the user before making any changes.

---

## Step 3 — Implement or update the Resource

### If no Resource file exists, create one

- **File location:** `Sources/TraktKit/Resources/<Name>Resource.swift`
- Follow the structure of `PeopleResource.swift` exactly
- Create a **collection resource** (e.g. `ListsResource`) for endpoints with no `id` parameter — accessed as a computed `var` on `TraktManager`
- Create a **single-item resource** (e.g. `ListResource`) for endpoints that take an `id` — accessed via a factory `func` on `TraktManager`
- If the API group has a `my/` (OAuth) vs `all/` (public) split, create two separate structs (e.g. `MyCalendarsResource` and `AllCalendarsResource`)
- Both structs go in the **same file**

### If a Resource file already exists

- Compare every endpoint in the API doc against every function in the Resource
- Add any missing endpoints
- Update documentation comments on existing functions to match the current API docs

### Route rules

- Every method returns a `Route<T>` or `EmptyRoute` — never `async throws` directly
- Use `Route(paths: [CustomStringConvertible?], ...)` for paths with optional segments — `nil` values are dropped automatically, so optional parameters like `startDate` and `days` work without any `if let`
- Use `Route(path: "...", ...)` only for fully static paths with no optional segments
- Use `PagedObject<[T]>` as the return type whenever the API doc shows `📄 Pagination`
- Use `EmptyRoute` for endpoints that return no body (201 or 204 responses)
- Set `requiresAuthentication: true` whenever the API doc shows `🔒 OAuth Required`
- For `🔓 OAuth Optional` endpoints, add an `authenticate: Bool = false` parameter and pass it to `requiresAuthentication:`

### Models

- **Always reuse existing Codable models.** Search the project thoroughly before creating anything new.
- If a new model is genuinely needed, add it to the most relevant **existing** model file (e.g. add `PersonUpdate` to `Update.swift`) rather than creating a new file.
- Never create a new file just for a model.

### Documentation comments

Every function must include documentation with the following elements:

1. **Description** - Copy from the Trakt API docs
2. **Endpoint line** - HTTP method and path matching the API Blueprint format from `docs/api/trakt.apib`
3. **Capability indicators** - Standard emoji indicators from the API docs

**Format:**

```swift
/// Get all movie releases for a country
///
/// **Endpoint:** `GET /movies/{id}/releases/{country}`
/// ✨ Extended Info
public func releases(country: String) -> Route<[TraktMovieRelease]> { ... }
```

**Key rules:**
- Use `{param}` notation (not `:param`) to match the API Blueprint format
- Place the endpoint line immediately after the description, before capability indicators
- Include all applicable capability indicators from the table below

| Indicator | Meaning |
|---|---|
| `📄 Pagination` | Endpoint is paginated — return type must be `PagedObject` |
| `✨ Extended Info` | Supports `?extended=` query parameter |
| `🔒 OAuth Required` | Always set `requiresAuthentication: true` |
| `🔓 OAuth Optional` | Add `authenticate: Bool = false` parameter |
| `🔥 VIP Only` | Note in the doc comment |
| `😁 Emojis` | Response may contain emoji |
| `🎚 Filters` | Supports filter query parameters |

### Add accessors to `TraktManager+Resources.swift`

- Computed `var` for collection resources:
  ```swift
  public var lists: ListsResource {
      ListsResource(traktManager: self)
  }
  ```
- Factory `func` for single-item resources:
  ```swift
  /// - parameter id: Trakt ID or Trakt slug
  public func list(id: CustomStringConvertible) -> ListResource {
      ListResource(id: id, traktManager: self)
  }
  ```
- Group under a `// MARK: - <GroupName>` comment
- Insert in **alphabetical order** among the existing MARK sections

---

## Step 4 — Implement or update the tests

### File and folder locations

| What | Where |
|---|---|
| Test file | `Tests/TraktKitTests/ResourceTests/<Name>Tests.swift` |
| JSON fixtures | `Tests/TraktKitTests/Models/<GroupName>/<fixture_name>.json` |

> **Critical:** Create files at their actual path. Do **not** encode the folder path into the filename.
>
> ✅ Correct: create file at path `Tests/TraktKitTests/Models/Calendars/test_get_calendar_shows.json`
> ❌ Wrong: create file named `TestsTraktKitTestsModelsCalendarstest_get_calendar_shows.json` in the wrong folder

### Test file structure

Every test file must follow this exact structure:

```swift
import Foundation
import Testing
@testable import TraktKit

extension TraktTestSuite {
    @Suite(.serialized)
    struct <Name>Tests {
        // tests...
    }
}
```

Rules:
- `import Foundation` is **always required** — `Date` and other Foundation types are used by the test helpers
- Always extend `TraktTestSuite` — never create a standalone class
- Use `@Suite(.serialized)` on every suite struct
- Each `@Test func` creates its own `traktManager` via `await authenticatedTraktManager()`
- Call `try mock(...)` from `TraktTestSuite` — never instantiate `RequestMocking` directly
- Use `#expect(...)` and `try #require(...)` — never `XCTAssert`

### Writing each test

Write one `@Test` function per endpoint. Each test must:

1. Mock the exact URL the `Route` will produce. Query parameters are appended in this order by the `Route` builder: `extended`, then `page`, then `limit`
2. Call `jsonData(named: "fixture_name")` — the name must match the JSON filename without the `.json` extension
3. Call the method under test via the `traktManager` chain ending in `.perform()`
4. Assert at minimum:
   - The count of a collection, **or** a key scalar field for a single object
   - At least one **nested** field to confirm decoding worked (e.g. a title, a slug, an id)
5. For `EmptyRoute` endpoints (`like()`, `refresh()`, etc.): simply confirm the call does not throw — no result to assert
6. For paginated endpoints: pass `headers: [.page(1), .pageCount(N)]` to the mock and assert `result.currentPage` and `result.pageCount`

### Deterministic dates in test URLs

When a method takes a `Date` that ends up in the URL, **always** build it from `DateComponents` with an explicit UTC timezone. Never use `Date()`, string parsing helpers, or any relative value.

```swift
var components = DateComponents()
components.timeZone = TimeZone(identifier: "UTC")
components.year = 2014
components.month = 9
components.day = 1
let date = Calendar(identifier: .gregorian).date(from: components)!
```

If the same date is used across multiple tests in a suite, declare it as a `private static var` computed property on the suite struct.

### Writing JSON fixtures

- Use the **example JSON from the Trakt API documentation** wherever it is provided
- If the API doc does not provide example values, construct minimal but realistic JSON that satisfies the Codable model
- Every field that is non-optional in the Swift model **must** be present
- Date strings follow the rules in `DateParser.swift`:
  - Full datetime: `"2014-09-01T01:00:00.000Z"`
  - Date only: `"2014-09-01"` (any string ≤ 10 characters)
- Fixtures can be **reused** across tests when the response shape is identical (e.g. `my/shows` and `all/shows` both return `[CalendarShow]`)
- Name fixtures descriptively: `test_get_calendar_shows.json`, `test_get_list_items.json`

---

## Step 5 — Review checklist before finishing

Do not report done until all of these are true:

- [ ] Every endpoint in the API group's documentation has a corresponding function in the Resource
- [ ] Every function has a corresponding `@Test`
- [ ] Every test has a corresponding JSON fixture at the **correct path** with the correct filename
- [ ] No file has the folder path encoded into its filename
- [ ] `TraktManager+Resources.swift` has accessors for any new Resource structs
- [ ] No new model type was created when an existing one could be reused
- [ ] `import Foundation` is present in every new test file

---

## Quick reference

### Route patterns

```swift
// Static path, no optional segments
Route(path: "lists/trending", method: .GET, traktManager: traktManager)

// Path with optional segments — nil values are dropped
Route(paths: [basePath, "shows", date?.calendarDateString(), days], method: .GET, ...)

// Paginated response
Route<PagedObject<[TraktMovie]>>(...)

// No response body (201 / 204)
EmptyRoute(paths: [path, "like"], method: .POST, requiresAuthentication: true, traktManager: traktManager)
```

### Accessor patterns in `TraktManager+Resources.swift`

```swift
// Collection resource (no id)
public var lists: ListsResource {
    ListsResource(traktManager: self)
}

// Single-item resource (with id)
/// - parameter id: Trakt ID or Trakt slug
public func list(id: CustomStringConvertible) -> ListResource {
    ListResource(id: id, traktManager: self)
}
```

### Common return types

| API response | Swift return type |
|---|---|
| Single object | `Route<TraktMovie>` |
| Array, not paginated | `Route<[TraktMovie]>` |
| Array, paginated | `Route<PagedObject<[TraktMovie]>>` |
| No body | `EmptyRoute` |

### When to split into two structs

| Pattern | Example |
|---|---|
| Collection vs single item | `MoviesResource` + `MovieResource` |
| Public vs authenticated | `AllCalendarsResource` + `MyCalendarsResource` |
