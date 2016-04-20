<p align="center">
    <img src="http://maximilianlitteral.com/TraktKit.png" alt="Logo" />
</p>

#TraktKit
Swift wrapper for Trakt.tv  API.

###Usage

In your AppDelegate, under <code>application(application:, didFinishLaunchingWithOptions launchOptions:)</code> place:
```
TraktManager.sharedManager.setClientID("Client ID", clientSecret: "Secret", redirectURI: "Redirect URI")
```

###Authentication
```
guard let oathURL = TraktManager.sharedManager.oauthURL else { return }

let traktAuth = SFSafariViewController(URL: oathURL)
traktAuth.delegate = self
self.presentViewController(traktAuth, animated: true, completion: nil)
```

In AppDelegate.swift
```
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

###Get Show information
```
TraktManager.sharedManager.getShowSummary(showID: "the-last-man-on-earth", extended: .FullAndImages) { (dictionary, error) -> Void in        
            guard error == nil else {
                // Handle error
                return
            }
            
            guard let summary = dictionary else {
                completion(newShow: nil)
                return
            }
        }
```

###License
The MIT License (MIT)

Copyright (c) 2016 Maximilian Litteral

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
