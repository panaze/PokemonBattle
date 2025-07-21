//
//  DefeatViewController.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - Defeat View Controller

/// View controller displayed when the player loses a battle
class DefeatViewController: UIViewController {
    // MARK: - Properties
    private let playerPokemon: PlayerPokemon
    weak var coordinator: MainCoordinator?
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let defeatContainerView = UIView()
    private let defeatLabel = UILabel()
    private let pokemonImageView = UIImageView()
    private let messageLabel = UILabel()
    private let encouragementLabel = UILabel()
    private let returnToMenuButton = UIButton(type: .system)
    // MARK: - Initialization
    init(playerPokemon: PlayerPokemon) {
        self.playerPokemon = playerPokemon
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPokemonImage()
    }
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Defeat"
        setupScrollView()
        setupDefeatContainer()
        setupDefeatLabel()
        setupPokemonImageView()
        setupLabels()
        setupButtons()
        setupConstraints()
    }
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    private func setupDefeatContainer() {
        defeatContainerView.backgroundColor = .systemBackground
        defeatContainerView.layer.cornerRadius = 16
        defeatContainerView.layer.shadowColor = UIColor.black.cgColor
        defeatContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        defeatContainerView.layer.shadowRadius = 8
        defeatContainerView.layer.shadowOpacity = 0.08
        defeatContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(defeatContainerView)
    }
    private func setupDefeatLabel() {
        defeatLabel.text = "Defeat"
        defeatLabel.textAlignment = .center
        defeatLabel.font = .systemFont(ofSize: 32, weight: .bold)
        defeatLabel.textColor = .systemRed
        defeatLabel.translatesAutoresizingMaskIntoConstraints = false
        defeatContainerView.addSubview(defeatLabel)
    }
    private func setupPokemonImageView() {
        pokemonImageView.contentMode = .scaleAspectFit
        pokemonImageView.backgroundColor = .systemGray6
        pokemonImageView.layer.cornerRadius = 12
        pokemonImageView.layer.borderWidth = 2
        pokemonImageView.layer.borderColor = UIColor.systemGray4.cgColor
        pokemonImageView.clipsToBounds = true
        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        defeatContainerView.addSubview(pokemonImageView)
    }
    private func setupLabels() {
        // Message label
        messageLabel.text = "\(playerPokemon.name) was defeated!"
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 20, weight: .medium)
        messageLabel.textColor = .label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        // Encouragement label
        encouragementLabel.text = "Don't give up, trainer!\nEvery defeat is a step towards victory."
        encouragementLabel.numberOfLines = 0
        encouragementLabel.textAlignment = .center
        encouragementLabel.font = .systemFont(ofSize: 16, weight: .regular)
        encouragementLabel.textColor = .secondaryLabel
        encouragementLabel.translatesAutoresizingMaskIntoConstraints = false
        defeatContainerView.addSubview(messageLabel)
        defeatContainerView.addSubview(encouragementLabel)
    }
    private func setupButtons() {
        // Return to menu button
        returnToMenuButton.setTitle("Return to Menu", for: .normal)
        returnToMenuButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        returnToMenuButton.backgroundColor = .systemBlue
        returnToMenuButton.setTitleColor(.white, for: .normal)
        returnToMenuButton.layer.cornerRadius = 16
        returnToMenuButton.layer.shadowColor = UIColor.systemBlue.cgColor
        returnToMenuButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        returnToMenuButton.layer.shadowRadius = 8
        returnToMenuButton.layer.shadowOpacity = 0.3
        // Add pressed state
        returnToMenuButton.setBackgroundImage(UIImage(color: .systemBlue.withAlphaComponent(0.8)), for: .highlighted)
        returnToMenuButton.addAction(UIAction { [weak self] _ in
            self?.returnToMenuTapped()
        }, for: .touchUpInside)
        returnToMenuButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(returnToMenuButton)
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // Defeat container constraints
            defeatContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            defeatContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            defeatContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // Defeat label
            defeatLabel.topAnchor.constraint(equalTo: defeatContainerView.topAnchor, constant: 24),
            defeatLabel.leadingAnchor.constraint(equalTo: defeatContainerView.leadingAnchor, constant: 24),
            defeatLabel.trailingAnchor.constraint(equalTo: defeatContainerView.trailingAnchor, constant: -24),
            // Pokemon image
            pokemonImageView.topAnchor.constraint(equalTo: defeatLabel.bottomAnchor, constant: 24),
            pokemonImageView.centerXAnchor.constraint(equalTo: defeatContainerView.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 140),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 140),
            // Message label
            messageLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: defeatContainerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: defeatContainerView.trailingAnchor, constant: -24),
            // Encouragement label
            encouragementLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            encouragementLabel.leadingAnchor.constraint(equalTo: defeatContainerView.leadingAnchor, constant: 24),
            encouragementLabel.trailingAnchor.constraint(equalTo: defeatContainerView.trailingAnchor, constant: -24),
            encouragementLabel.bottomAnchor.constraint(equalTo: defeatContainerView.bottomAnchor, constant: -24),
            // Return to menu button
            returnToMenuButton.topAnchor.constraint(equalTo: defeatContainerView.bottomAnchor, constant: 32),
            returnToMenuButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            returnToMenuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            returnToMenuButton.heightAnchor.constraint(equalToConstant: 56),
            returnToMenuButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    private func loadPokemonImage() {
        // Set placeholder image with better styling
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        pokemonImageView.image = UIImage(systemName: "photo", withConfiguration: config)
        pokemonImageView.tintColor = .systemGray3
        // Load Pokemon sprite image
        guard let url = URL(string: playerPokemon.frontSpriteURL) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.pokemonImageView.image = image
                        self.pokemonImageView.tintColor = nil
                    }
                }
            } catch {
                // Handle image loading error silently with better placeholder
                await MainActor.run {
                    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
                    self.pokemonImageView.image = UIImage(systemName: "questionmark.circle", withConfiguration: config)
                    self.pokemonImageView.tintColor = .systemGray3
                }
            }
        }
    }
    private func returnToMenuTapped() {
        // Return to battle menu
        coordinator?.didRequestReturnToMenu()
    }
}

// MARK: - UIImage Extension for Button States

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
