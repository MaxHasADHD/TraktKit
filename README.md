<p align="center">
    <img src="http://maximilianlitteral.com/TraktKit.png" alt="Logo" />
</p>

# TraktKit
Swift wrapper for Trakt.tv  API.

## Requirements

- iOS 10.0+ / macOS 10.10+ / watchOS 3.0+
- Xcode 9.2+
- Swift 4.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1+ is required to build TraktKit 1.0.0+.

To integrate TraktKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'TraktKit', '~> 1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TraktKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "MaxHasADHD/TraktKit" ~> 1.0.0
```

Run `carthage update` to build the framework and drag the built `TraktKit.framework` into your Xcode project.    

### Usage

In your AppDelegate, under <code>application(application:, didFinishLaunchingWithOptions launchOptions:)</code> place:
```swift
TraktManager.sharedManager.set(clientID: "Client ID", clientSecret: "Secret", redirectURI: "Redirect URI")
```

### Authentication
```swift
guard let oauthURL = TraktManager.sharedManager.oauthURL else { return }

let traktAuth = SFSafariViewController(URL: oathURL)
traktAuth.delegate = self
self.presentViewController(traktAuth, animated: true, completion: nil)
```

In AppDelegate.swift
```swift
func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
    let urlString = url.absoluteString

    let queryDict = url.queryDict() // Parse URL

    if url.host == "auth" {
        if let code = queryDict["code"] as? String { // Get authorization code
            TraktManager.sharedManager.getTokenFromAuthorizationCode(code, completionHandler: nil)
        }
    }
    return true
}
```

### Get Show information
```swift
TraktManager.sharedManager.getShowSummary(showID: "the-last-man-on-earth", extended: [.Full, .Images]) { (result) in
            switch result {
            case .success(let result):
                // Process result
                break
            case .error(let error):
                // Handle error
                break
            }
        }
```

### Search - This will find Batman movies with ratings between 75% and 100%
```swift
TraktManager.sharedManager.search(query: "Batman",
                                          types: [.movie],
                                          extended: [.Full, .Images],
                                          pagination: Pagination(page: 1, limit: 20),
                                          filters: [.ratings(ratings: (lower: 75, upper: 100))]) { (result) in
            switch result {
            case .success(let results):
                for result in results {
                    guard let movie = result.movie else { continue }
                    // Handle movie
                }
            case .error(let error):
                print(error?.localizedDescription)
            }
        }
```

### License
The MIT License (MIT)

Copyright (c) 2016 Maximilian Litteral

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
