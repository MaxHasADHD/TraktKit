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

extension URL {
    func queryDict() -> [String: Any] {
        var dict = [String: Any]()
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                dict[item.name] = item.value
            }
        }
        return dict
    }
}

let traktManager = TraktManager(
    clientId: AppDelegate.Constants.clientId,
    redirectURI: AppDelegate.Constants.redirectURI
)

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    struct Constants {
        static let clientId = "YOUR CLIENT ID"
        static let redirectURI = "YOUR REDIRECT URI" // Something like 'traktkit://auth/trakt', and make sure to register 'YourScheme://' in the info.plist, this should be unique to your app
        // Get keys from https://trakt.tv/oauth/applications
        // Note: This example uses PKCE flow, so client secret is not needed
    }

    var window: UIWindow?
    
    // Store the code verifier for PKCE flow
    static var pkceCodeVerifier: String?

    // MARK: - Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup window with loading state
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let loadingViewController = LoadingViewController()
        window?.rootViewController = loadingViewController
        window?.makeKeyAndVisible()
        
        Task {
            try? await traktManager.refreshCurrentAuthState()
            
            await MainActor.run {
                if traktManager.isSignedIn {
                    window?.rootViewController = MainViewController()
                } else {
                    window?.rootViewController = LoginViewController()
                }
            }
        }
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        let queryDict = url.queryDict() // Parse URL

        if url.host == "auth",
            let code = queryDict["code"] as? String { // Get authorization code

            Task { @MainActor in
                do {
                    // Use PKCE flow with the stored code verifier
                    guard let codeVerifier = AppDelegate.pkceCodeVerifier else {
                        print("Error: Code verifier not found")
                        return
                    }
                    
                    _ = try await traktManager.getToken(authorizationCode: code, codeVerifier: codeVerifier)
                    print("Signed in to Trakt using PKCE")
                    
                    // Clear the code verifier after use
                    AppDelegate.pkceCodeVerifier = nil
                    
                    NotificationCenter.default.post(name: .TraktSignedIn, object: nil)
                } catch {
                    print("Failed to get token: \(error)")
                }
            }
        }

        return true
    }
}
