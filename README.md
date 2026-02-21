![TraktKit Logo](docs/assets/TraktKit.png)

# TraktKit
Swift wrapper for Trakt.tv  API.

[![SPM: Compatible](https://img.shields.io/badge/SPM-Compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Platforms: iOS | watchOS | macCatalyst | macOS | tvOS | visionOS](https://img.shields.io/badge/Platforms-iOS%20%7C%20watchOS%20%7C%20macCatalyst%20%7C%20macOS%20%7C%20tvOS%20%7C%20visionOS-blue.svg?style=flat)]
[![Language: Swift 6.0](https://img.shields.io/badge/Language-Swift%206.0-F48041.svg?style=flat)](https://developer.apple.com/swift)
[![License: MIT](http://img.shields.io/badge/License-MIT-lightgray.svg?style=flat)](https://github.com/MaxHasADHD/TraktKit/blob/master/License.md)


## Installation

### Swift Package Manager

You can use Xcode 11 or later to integrate TraktKit into your project using [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

To integrate TraktKit into your Xcode project using Swift Package Manager. Select **File > Swift Packages > Add Package Dependency...**.

When prompted, simply search for TraktKit or specify the project's GitHub repository:

```
https://github.com/MaxHasADHD/TraktKit
```

## Migrating to Version 2.0.0

TraktKit 2.0.0 introduces a modern async/await API while maintaining backwards compatibility through deprecated completion handler methods. All completion handler-based methods are now deprecated and will be removed in version 3.0.0.

For detailed migration instructions and examples, see the [Migration Guide](docs/MIGRATION_GUIDE.md).

### Key Changes in 2.0.0

- **Swift 6.0 with strict concurrency** - Full support for Swift 6 concurrency features
- **Async/await API** - All endpoints now support modern async/await syntax
- **Deprecated completion handlers** - Legacy completion handler methods are marked as deprecated with migration guidance
- **Resource-based organization** - Cleaner, more intuitive API structure
- **Type-safe requests** - Improved type safety with chainable route builders

### Quick Migration Example

**Before (Completion Handlers):**
```swift
traktManager.getTrendingMovies { result in
    switch result {
    case .success(let movies):
        print("Found \(movies.count) trending movies")
    case .error(let error):
        print("Error: \(error)")
    }
}
```

**After (Async/Await):**
```swift
let movies = try await traktManager.movies
    .trending()
    .perform()
    .object

print("Found \(movies.count) trending movies")
```

For more examples and detailed migration steps, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).

### Usage
See the [example project](https://github.com/MaxHasADHD/TraktKit/tree/master/Example) for usage

### Author
Maximilian Litteral

### License
The MIT License (MIT)

Copyright (c) 2015-2025 Maximilian Litteral

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
