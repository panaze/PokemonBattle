//
//  StarterSelectionViewController.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - Starter Selection View Controller

/// View controller for selecting a starter Pokemon from the classic trio
class StarterSelectionViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: MainCoordinator?
    // Service instances (Model layer)
    let pokemonRepository = PokemonRepository()
    let persistenceService = PersistenceService.shared
    // Data properties (Model state)
    var starterOptions: [StarterOption] = []
    var isLoading = false
    var errorMessage: String?
    let starterIDs = [1, 4, 7] // Bulbasaur, Charmander, Squirtle
    // MARK: - UI Components
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Your Starter Pokemon"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select one of these classic Pokemon to begin your journey!"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var starterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addAction(UIAction { [weak self] _ in
            self?.retryButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
        setupInitialStarters()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStarters()
    }
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Choose Your Starter"
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        // Add main components
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(starterStackView)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(errorLabel)
        contentView.addSubview(retryButton)
        setupConstraints()
        createStarterCards()
    }
    func createStarterCards() {
        // Create starter cards with current data
        for starter in starterOptions {
            let starterCard = createStarterCard(for: starter)
            starterStackView.addArrangedSubview(starterCard)
        }
    }
    func createStarterCard(for starter: StarterOption) -> UIView {
        let cardView = createCardView()
        let imageView = createImageView(for: starter)
        let nameLabel = createNameLabel(for: starter)
        let typeLabel = createTypeLabel(for: starter)
        let selectButton = createSelectButton(for: starter)
        cardView.addSubview(imageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(typeLabel)
        cardView.addSubview(selectButton)
        setupCardConstraints(
            cardView: cardView,
            imageView: imageView,
            nameLabel: nameLabel,
            typeLabel: typeLabel,
            selectButton: selectButton)
        return cardView
    }
    // MARK: - Actions
    func starterButtonTapped(_ sender: UIButton) {
        let pokemonID = sender.tag
        guard let selectedStarter = starterOptions.first(where: { $0.pokemon.id == pokemonID }) else {
            return
        }
        showLoading(true)
        Task {
            if let playerPokemon = await selectStarter(selectedStarter) {
                await MainActor.run {
                    showLoading(false)
                    coordinator?.didSelectStarter(playerPokemon)
                }
            } else {
                await MainActor.run {
                    showLoading(false)
                    updateUI()
                }
            }
        }
    }
    func retryButtonTapped() {
        hideError()
        showLoading(true)
        loadStarters()
    }
    // MARK: - UI Helper Methods
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError(error.localizedDescription)
    }
}

// MARK: - Starter Option Model

/// Represents a starter Pokemon option with its image and selection state
struct StarterOption {
    let pokemon: Pokemon
    var image: UIImage?
    var isSelected: Bool
    var displayName: String {
        return pokemon.name.capitalized
    }
    var typeColor: UIColor {
        switch pokemon.primaryType.lowercased() {
        case "grass":
            return UIColor.systemGreen
        case "fire":
            return UIColor.systemRed
        case "water":
            return UIColor.systemBlue
        default:
            return UIColor.systemGray
        }
    }
}
