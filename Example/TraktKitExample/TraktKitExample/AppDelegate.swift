//
//  AppDelegate.swift
//  TraktKitExample
//
//  Created by Litteral, Maximilian on 1/11/19.
//  Copyright © 2019 Maximilian Litteral. All rights reserved.
//

import UIKit
import TraktKit

extension Notification.Name {
    static let TraktSignedIn = Notification.Name(rawValue: "TraktSignedIn")
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    private struct Constants {
        static let clientId = "FILL"
        static let clientSecret = "ME"
        static let redirectURI = "IN" // Something like 'traktkit://auth/trakt', and make sure to register 'YourScheme://' in the info.plist, this should be unique to your app
        // Get keys from https://trakt.tv/oauth/applications
    }

    let traktManager = TraktManager(
        clientId: Constants.clientId,
        clientSecret: Constants.clientSecret,
        redirectURI: Constants.redirectURI
    )

    var window: UIWindow?

    // MARK: - Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DependencyContainer.shared.traktClient = traktManager
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        let queryDict = url.queryDict() // Parse URL

        if url.host == "auth",
            let code = queryDict["code"] as? String { // Get authorization code

            Task { @MainActor in
                do {
                    let authorization = try await traktManager.getToken(authorizationCode: code)
                    print("Signed in to Trakt")
                    NotificationCenter.default.post(name: .TraktSignedIn, object: nil)
                } catch {
                    print("Failed to get token: \(error)")
                }
            }
        }

        return true
    }
}

extension URL {
    func queryDict() -> [String: Any] {
        var info: [String: Any] = [String: Any]()
        if let queryString = self.query{
            for parameter in queryString.components(separatedBy: "&"){
                let parts = parameter.components(separatedBy: "=")
                if parts.count > 1 {
                    let key = parts[0].removingPercentEncoding
                    let value = parts[1].removingPercentEncoding
                    if key != nil && value != nil{
                        info[key!] = value
                    }
                }
            }
        }
        return info
    }
}

