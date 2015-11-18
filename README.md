#Trakt Kit
Swift wrapper for Trakt.tv  API.

#Usage

In your AppDelegate, under <code>application(application:, didFinishLaunchingWithOptions launchOptions:)</code> place:
```
TraktManager.sharedManager.setClientID("Client ID", clientSecret: "Secret", redirectURI: "Redirect URI")
```
