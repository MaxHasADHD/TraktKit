//
//  MainViewController.swift
//  TraktKitExample
//
//  Created by Maximilian Litteral on 2/22/26.
//

import UIKit

final class MainViewController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupTabs() {
        let watchlistVC = WatchlistViewController()
        let watchlistNav = UINavigationController(rootViewController: watchlistVC)
        
        let notesVC = NotesViewController()
        let notesNav = UINavigationController(rootViewController: notesVC)
        
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        
        let watchlistTab = UITab(title: "Watchlist", image: UIImage(systemName: "bookmark"), identifier: "watchlist") { _ in
            watchlistNav
        }
        
        let notesTab = UITab(title: "Notes", image: UIImage(systemName: "note.text"), identifier: "notes") { _ in
            notesNav
        }
        
        let searchTab = UISearchTab(viewControllerProvider: { _ in
            searchNav
        })
        
        tabs = [watchlistTab, notesTab, searchTab]
    }
    
    private func setupNavigationBar() {
        // Configure appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
