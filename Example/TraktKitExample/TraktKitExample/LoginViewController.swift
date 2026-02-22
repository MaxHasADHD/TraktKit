//
//  LoginViewController.swift
//  TraktKitExample
//
//  Created by Maximilian Litteral on 2/22/26.
//

import UIKit
import SafariServices
import TraktKit

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TraktKit"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signInButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign In with Trakt"
        config.cornerStyle = .large
        config.buttonSize = .large
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.presentLogin()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            // Title label - above center
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Sign in button - bottom
            signInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSignIn),
            name: .TraktSignedIn,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    private func presentLogin() {
        // Generate PKCE code verifier and challenge
        let codeVerifier = PKCEUtilities.generateCodeVerifier()
        let codeChallenge = PKCEUtilities.generateCodeChallenge(from: codeVerifier)
        
        // Store the code verifier for later use in the token exchange
        AppDelegate.pkceCodeVerifier = codeVerifier
        
        guard let oauthURL = traktManager.oauthURL(codeChallenge: codeChallenge) else { return }
        
        let traktAuth = SFSafariViewController(url: oauthURL)
        present(traktAuth, animated: true, completion: nil)
    }
    
    @objc private func handleSignIn() {
        dismiss(animated: true) { [weak self] in
            self?.transitionToMainInterface()
        }
    }
    
    private func transitionToMainInterface() {
        let mainViewController = MainViewController()
        
        // Update the window's root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainViewController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
