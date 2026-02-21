//
//  ViewController.swift
//  TraktKitExample
//
//  Created by Litteral, Maximilian on 1/11/19.
//  Copyright © 2019 Maximilian Litteral. All rights reserved.
//

import Combine
import UIKit
import SafariServices
import TraktKit

final class ViewController: UIViewController {

    // MARK: - Properties

    private let stackView = UIStackView()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }

    // MARK: - Actions

    private func presentLogIn() {
        guard let oauthURL = traktManager.oauthURL else { return }

        let traktAuth = SFSafariViewController(url: oauthURL)
        present(traktAuth, animated: true, completion: nil)
    }

    private func signOut() {
        traktManager.signOut()
        refreshUI()
    }

    private func presentUserInfo() {
        let profileViewController = TraktProfileViewController()
        show(profileViewController, sender: self)
    }

    private func searchForShow() {
        let alertController = UIAlertController(title: "Show name?", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            if #available(iOS 11.0, *) {
                textField.smartQuotesType = .no // Smart quotes effect search results, always turn off.
            }
            textField.autocorrectionType = .no
            textField.returnKeyType = .search
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak navigationController] _ in
            guard let query = alertController.textFields?.first?.text else { return }
            let searchResultsViewController = SearchResultsViewController(query: query)
            navigationController?.pushViewController(searchResultsViewController, animated: true)
        }
        alertController.addAction(searchAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: Setup

    private func setup() {
        self.title = "TraktKit"
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        refreshUI()
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default
            .publisher(for: .TraktSignedIn)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                dismiss(animated: true, completion: nil) // Dismiss the SFSafariViewController
                refreshUI()
            }
            .store(in: &cancellables)
    }

    private func refreshUI() {
        func createButton(title: String, action: @escaping (UIButton) -> Void) -> UIButton {
            let button = ClosureButton(type: .system)
            button.setTitle(title, for: .normal)
            button.action = action
            return button
        }

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var views = [UIView]()

        if traktManager.isSignedIn {
            let signInButton = createButton(title: "Sign Out", action: { [weak self] _ in self?.signOut() })
            views.append(signInButton)

            let presentLoginButton = createButton(title: "View Profile") { [weak self] _ in
                self?.presentUserInfo()
            }
            views.append(presentLoginButton)

            let showSearchButton = createButton(title: "Search for Show") { [weak self] _ in
                self?.searchForShow()
            }
            views.append(showSearchButton)
        } else {
            let signInButton = createButton(title: "Sign In", action: { [weak self] _ in self?.presentLogIn() })
            views.append(signInButton)
        }

        views.forEach { stackView.addArrangedSubview($0) }
    }
}

final class ClosureButton: UIButton {
    var action: ((UIButton) -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }

    @objc private func didTouchUpInside(_ sender: UIButton) {
        action?(sender)
    }
}
