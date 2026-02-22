//
//  NotesViewController.swift
//  TraktKitExample
//
//  Created by Maximilian Litteral on 2/22/26.
//

import UIKit
import Kingfisher

final class NotesViewController: UIViewController {
    
    // MARK: - Types
    
    private enum Section {
        case main
    }
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Note>!
    private var isLoading = false {
        didSet {
            updateContentUnavailableConfiguration()
        }
    }
    private var notes: [Note] = [] {
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

        Task { @MainActor in
            isLoading = true
            do {
                let result = try await traktManager.user("me").notes(type: "movie").limit(100).extend(.images).perform().object
                notes = result.map { Note(content: $0.note.notes, mediaItem: .init(from: $0.movie!))}
            } catch {
                print("Failed to get notes: \(error)")
            }
            isLoading = false
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Notes"
        view.backgroundColor = .systemBackground
        
        setupUserMenu()
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
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = true
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<NoteCell, Note> { cell, indexPath, note in
            cell.configure(with: note)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Note>(collectionView: collectionView) { collectionView, indexPath, note in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: note)
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections([.main])
        snapshot.appendItems(notes)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateContentUnavailableConfiguration() {
        if isLoading {
            var config = UIContentUnavailableConfiguration.loading()
            config.text = "Loading Notes"
            contentUnavailableConfiguration = config
        } else if notes.isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "note.text.badge.plus")
            config.text = "No Notes"
            config.secondaryText = "Add notes about shows and movies you've watched"
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    

}

// MARK: - NoteCell

final class NoteCell: UICollectionViewCell {
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mediaInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(contentStackView)
        
        textStackView.addArrangedSubview(contentLabel)
        textStackView.addArrangedSubview(mediaInfoLabel)
        
        contentStackView.addArrangedSubview(textStackView)
        contentStackView.addArrangedSubview(thumbnailImageView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    func configure(with note: Note) {
        contentLabel.text = note.content
        mediaInfoLabel.text = "\(note.mediaItem.title) • \(note.mediaItem.type.rawValue)"
        
        // Load image using Kingfisher
        if let imageURL = note.mediaItem.imageURL {
            thumbnailImageView.kf.setImage(
                with: imageURL,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            thumbnailImageView.image = nil
        }
    }
}
