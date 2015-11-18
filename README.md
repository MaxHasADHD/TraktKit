#Trakt Kit
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
