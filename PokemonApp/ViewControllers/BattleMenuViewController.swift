//
//  BattleMenuViewController.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - Battle Menu View Controller

/// View controller for the main battle menu where players can initiate battles
/// Displays player Pokemon stats and provides opponent generation functionality
class BattleMenuViewController: UIViewController {
    // MARK: - Properties
    private var playerPokemon: PlayerPokemon
    private var isGeneratingOpponent = false
    // Direct service instances
    private let pokemonRepository = PokemonRepository()
    private let persistenceService = PersistenceService.shared
    // Coordinator reference (concrete type)
    weak var coordinator: MainCoordinator?
    // MARK: - UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let playerInfoContainerView = UIView()
    let pokemonImageView = UIImageView()
    let playerNameLabel = UILabel()
    let playerStatsLabel = UILabel()
    let evolutionInfoLabel = UILabel()
    let findOpponentButton = UIButton(type: .system)
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
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
        updatePlayerInfo()
        loadPokemonSprite()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh player info in case Pokemon evolved or stats changed
        updatePlayerInfo()
    }
    // MARK: - Private Methods
    private func updatePlayerInfo() {
        // Update Pokemon name
        playerNameLabel.text = playerPokemon.name
        // Update stats with better formatting
        let experienceToNext = getExperienceToNextLevel()
        let statsText = createFormattedStatsText(experienceToNext: experienceToNext)
        playerStatsLabel.attributedText = statsText
        // Update evolution info
        let evolutionText = getEvolutionInfoText()
        evolutionInfoLabel.text = evolutionText
        evolutionInfoLabel.isHidden = evolutionText.isEmpty
    }
    private func createFormattedStatsText(experienceToNext: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        // Create styled stat rows
        let stats = [
            ("Level", "\(playerPokemon.level)"),
            ("Experience", "\(playerPokemon.experience)\(experienceToNext)"),
            ("HP", "\(playerPokemon.currentHP) / \(playerPokemon.maxHP)"),
            ("Type", playerPokemon.primaryType.capitalized)
        ]
        for (index, (label, value)) in stats.enumerated() {
            // Label style
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.label
            ]
            // Value style
            let valueAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let labelString = NSAttributedString(string: "\(label): ", attributes: labelAttributes)
            let valueString = NSAttributedString(string: value, attributes: valueAttributes)
            attributedString.append(labelString)
            attributedString.append(valueString)
            // Add line break if not the last item
            if index < stats.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }
        // Add paragraph style for better line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    private func getEvolutionStageText() -> String {
        switch playerPokemon.evolutionStage {
        case 0: return "Base Form"
        case 1: return "Second Stage"
        case 2: return "Final Stage"
        default: return "Unknown"
        }
    }
    private func getEvolutionInfoText() -> String {
        if playerPokemon.canEvolve {
            let nextLevel = playerPokemon.evolutionStage == 0 ? 8 : 16
            return "Ready to evolve at level \(nextLevel)!"
        } else if playerPokemon.evolutionStage < 2 {
            let nextLevel = playerPokemon.evolutionStage == 0 ? 8 : 16
            let levelsNeeded = nextLevel - playerPokemon.level
            return "Next evolution in \(levelsNeeded) level\(levelsNeeded == 1 ? "" : "s")"
        } else {
            return "Fully evolved!"
        }
    }
    private func getExperienceToNextLevel() -> String {
        // Calculate experience needed for next level (50 XP per level starting from level 5)
        let nextLevel = playerPokemon.level + 1
        let nextLevelExp = (nextLevel - 5) * 50
        let expToNext = nextLevelExp - playerPokemon.experience
        if expToNext > 0 {
            return " (\(expToNext) to next level)"
        } else {
            return ""
        }
    }
    private func loadPokemonSprite() {
        // Set placeholder image with better styling
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        pokemonImageView.image = UIImage(systemName: "photo", withConfiguration: config)
        pokemonImageView.tintColor = .systemGray3
        // Load Pokemon sprite asynchronously
        Task {
            do {
                let imageData = try await NetworkService.shared.downloadImage(from: playerPokemon.frontSpriteURL)
                guard let image = UIImage(data: imageData) else { return }
                await MainActor.run {
                    self.pokemonImageView.image = image
                    self.pokemonImageView.tintColor = nil
                }
            } catch {
                // Keep placeholder image on error
                print("Failed to load Pokemon sprite: \(error)")
            }
        }
    }
    func findOpponentTapped() {
        guard !isGeneratingOpponent else { return }
        setLoadingState(true)
        Task {
            do {
                // Generate random opponent with weighted distribution
                let pokemon = try await pokemonRepository.fetchRandomOpponent()
                let opponent = pokemonRepository.createOpponentPokemon(from: pokemon)
                await MainActor.run {
                    self.setLoadingState(false)
                    // Navigate to battle with direct coordinator reference
                    self.coordinator?.showBattle(player: self.playerPokemon, opponent: opponent)
                }
            } catch {
                await MainActor.run {
                    self.setLoadingState(false)
                    self.handleOpponentGenerationError(error)
                }
            }
        }
    }
    private func setLoadingState(_ isLoading: Bool) {
        isGeneratingOpponent = isLoading
        findOpponentButton.isEnabled = !isLoading
        if isLoading {
            findOpponentButton.setTitle("Finding Opponent...", for: .normal)
            findOpponentButton.alpha = 0.7
            loadingIndicator.startAnimating()
        } else {
            findOpponentButton.setTitle("Find Opponent", for: .normal)
            findOpponentButton.alpha = 1.0
            loadingIndicator.stopAnimating()
        }
    }
    private func handleOpponentGenerationError(_ error: Error) {
        // Show retry dialog for network errors
        if error is NetworkError {
            showRetryDialog(
                for: error,
                retryAction: { [weak self] in
                    self?.findOpponentTapped()
                }
            )
        } else {
            // Show generic error for other types
            showErrorAlert(error)
        }
    }
    // MARK: - Direct Error Handling Methods
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func showRetryDialog(for error: Error, retryAction: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Connection Error",
            message: error.localizedDescription + "\n\nWould you like to try again?",
            preferredStyle: .alert
        )
        let retryAlertAction = UIAlertAction(title: "Retry", style: .default) { _ in
            retryAction()
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(retryAlertAction)
        alert.addAction(cancelAlertAction)
        present(alert, animated: true)
    }
    // MARK: - Public Methods
    /// Updates the player Pokemon data (called when returning from battle)
    /// - Parameter updatedPokemon: The updated player Pokemon
    func updatePlayerPokemon(_ updatedPokemon: PlayerPokemon) {
        self.playerPokemon = updatedPokemon
        updatePlayerInfo()
        loadPokemonSprite()
    }
}
