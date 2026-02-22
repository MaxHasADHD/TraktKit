//
//  SearchViewController.swift
//  TraktKitExample
//
//  Created by Maximilian Litteral on 2/22/26.
//

import UIKit
import Kingfisher
import TraktKit

final class SearchViewController: UIViewController {
    
    // MARK: - Types
    
    private enum Section {
        case main
    }
    
    private enum SearchState {
        case initial
        case loading
        case results([MediaItem])
        case empty
    }
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MediaItem>!
    private var searchController: UISearchController!
    private var searchTask: Task<Void, Never>?
    
    private var searchState: SearchState = .initial {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupCollectionView()
        configureDataSource()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Search"
        view.backgroundColor = .systemBackground
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search shows and movies"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MediaItemCell, MediaItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, MediaItem>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func updateUI() {
        // Update collection view
        var snapshot = NSDiffableDataSourceSnapshot<Section, MediaItem>()
        snapshot.appendSections([.main])
        
        if case .results(let items) = searchState {
            snapshot.appendItems(items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        // Update content unavailable configuration
        switch searchState {
        case .initial:
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "magnifyingglass")
            config.text = "Search Shows & Movies"
            config.secondaryText = "Type a title to start searching"
            contentUnavailableConfiguration = config
            
        case .loading:
            var config = UIContentUnavailableConfiguration.loading()
            config.text = "Searching..."
            contentUnavailableConfiguration = config
            
        case .results(let items):
            contentUnavailableConfiguration = items.isEmpty ? UIContentUnavailableConfiguration.search() : nil
            
        case .empty:
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.search()
        }
    }
    
    private func performSearch(query: String) {
        // Cancel any existing search
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchState = .initial
            return
        }
        
        searchState = .loading
        
        searchTask = Task { @MainActor in
            do {
                let results = try await traktManager.search()
                    .search(query, types: [.movie, .show])
                    .extend(.images)
                    .perform()
                
                // Convert search results to MediaItems
                let items = results.compactMap { result -> MediaItem? in
                    if let movie = result.movie {
                        return MediaItem(from: movie)
                    } else if let show = result.show {
                        return MediaItem(from: show)
                    }
                    return nil
                }
                
                searchState = .results(items)
            } catch {
                if error is CancellationError {
                    return
                }
                print("Search failed: \(error)")
                searchState = .empty
            }
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        performSearch(query: searchText)
    }
}
