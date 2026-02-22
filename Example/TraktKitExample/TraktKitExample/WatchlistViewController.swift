//
//  WatchlistViewController.swift
//  TraktKitExample
//
//  Created by Maximilian Litteral on 2/22/26.
//

import UIKit
import Kingfisher

final class WatchlistViewController: UIViewController {
    
    // MARK: - Types
    
    private enum Section {
        case main
    }
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MediaItem>!
    private var isLoading = false {
        didSet {
            updateContentUnavailableConfiguration()
        }
    }
    private var items: [MediaItem] = [] {
        didSet {
            applySnapshot()
            updateContentUnavailableConfiguration()
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Watchlist"
        view.backgroundColor = .systemBackground
        
        setupUserMenu()
        
        Task { @MainActor in
            isLoading = true
            do {
                let result = try await traktManager.user("me").watchlist().limit(100).extend(.images).perform().object
                items = result.compactMap { $0.movie }.map { MediaItem.init(from: $0) }
            } catch {
                print("Failed to load watchlist: \(error)")
            }
            isLoading = false
        }
    }
    
    private func setupUserMenu() {
        Task { @MainActor in
            do {
                let userSettings = try await traktManager.currentUser().settings().perform()
                
                let username = userSettings.user.username ?? "User"
                let name = userSettings.user.name ?? username
                let isVIP = userSettings.user.isVIP ?? false
                let vipYears = userSettings.user.vipYears ?? 0
                
                var menuItems: [UIMenuElement] = [
                    UIAction(title: name, image: UIImage(systemName: "person.circle.fill"), attributes: .disabled) { _ in },
                    UIAction(title: "@\(username)", image: UIImage(systemName: "at"), attributes: .disabled) { _ in }
                ]
                
                if isVIP && vipYears > 0 {
                    menuItems.append(
                        UIAction(title: "VIP Member (\(vipYears) years)", image: UIImage(systemName: "star.fill"), attributes: .disabled) { _ in }
                    )
                }
                
                menuItems.append(
                    UIAction(title: "Sign Out", image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), attributes: .destructive) { [weak self] _ in
                        self?.signOut()
                    }
                )
                
                let menu = UIMenu(title: "", children: menuItems)
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: UIImage(systemName: "person.circle"),
                    menu: menu
                )
            } catch {
                print("Failed to load user info: \(error)")
            }
        }
    }
    
    private func signOut() {
        Task { @MainActor in
            // Clear authentication by updating state to nil
            await traktManager.updateCachedAuthState(nil)
            
            // Transition back to login screen
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = LoginViewController()
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
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
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MediaItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateContentUnavailableConfiguration() {
        if isLoading {
            var config = UIContentUnavailableConfiguration.loading()
            config.text = "Loading Watchlist"
            contentUnavailableConfiguration = config
        } else if items.isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "bookmark.slash")
            config.text = "No Watchlist Items"
            config.secondaryText = "Add shows and movies you want to watch"
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    

}

// MARK: - MediaItemCell

final class MediaItemCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(typeLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.5),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            typeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with item: MediaItem) {
        titleLabel.text = item.title
        typeLabel.text = item.type.rawValue
        
        // Load image using Kingfisher
        if let imageURL = item.imageURL {
            imageView.kf.setImage(
                with: imageURL,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            imageView.image = nil
        }
    }
}
