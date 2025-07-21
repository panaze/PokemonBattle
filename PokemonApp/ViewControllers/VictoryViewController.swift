//
//  VictoryViewController.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - Victory View Controller

/// View controller displayed when the player wins a battle
class VictoryViewController: UIViewController {
    // MARK: - Properties
    private var playerPokemon: PlayerPokemon
    private let experienceGained: Int
    weak var coordinator: MainCoordinator?
    private var levelUpResult: LevelUpResult?
    var victoryContainer: UIView!
    // Direct service instantiation
    private let evolutionService = EvolutionService(pokemonRepository: PokemonRepository())
    private let persistenceService = PersistenceService.shared
    // MARK: - UI Elements
    lazy var scrollView = createScrollView()
    lazy var contentView = createContentView()
    lazy var victoryLabel = createVictoryLabel()
    lazy var pokemonImageView = createPokemonImageView()
    lazy var experienceLabel = createExperienceLabel()
    lazy var levelUpLabel = createLevelUpLabel()
    lazy var evolutionLabel = createEvolutionLabel()
    lazy var evolveButton = createEvolveButton()
    lazy var continueButton = createContinueButton()
    // MARK: - Initialization
    init(playerPokemon: PlayerPokemon, experienceGained: Int, levelUpResult: LevelUpResult? = nil) {
        self.playerPokemon = playerPokemon
        self.experienceGained = experienceGained
        self.levelUpResult = levelUpResult
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateExperience()
    }
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Victory!"
        setupScrollView()
        setupVictoryContainer()
        addSubviewsToContentView()
        setupConstraints()
    }
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    private func setupVictoryContainer() {
        // Create victory info container similar to other views
        victoryContainer = UIView()
        victoryContainer.backgroundColor = .systemBackground
        victoryContainer.layer.cornerRadius = 16
        victoryContainer.layer.shadowColor = UIColor.black.cgColor
        victoryContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        victoryContainer.layer.shadowRadius = 8
        victoryContainer.layer.shadowOpacity = 0.08
        victoryContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(victoryContainer)
        // Add components to container
        victoryContainer.addSubview(victoryLabel)
        victoryContainer.addSubview(pokemonImageView)
        victoryContainer.addSubview(experienceLabel)
        victoryContainer.addSubview(levelUpLabel)
        victoryContainer.addSubview(evolutionLabel)
    }
    private func addSubviewsToContentView() {
        // Buttons go outside the container
        contentView.addSubview(evolveButton)
        contentView.addSubview(continueButton)
    }
    private func updateExperience() {
        // Load Pokemon image
        loadPokemonImage()
        // Display experience information
        let experienceText = """
        \(playerPokemon.name) gained \(experienceGained) experience!
        Total Experience: \(playerPokemon.experience)
        Current Level: \(playerPokemon.level)
        """
        experienceLabel.text = experienceText
        // Show level up information if applicable
        if let result = levelUpResult, result.leveledUp {
            levelUpLabel.text = "Level Up!\nLevel \(result.oldLevel) → \(result.newLevel)"
            levelUpLabel.isHidden = false
        }
        // Check if Pokemon can evolve and show evolve button
        if let result = levelUpResult, result.canEvolve {
            evolveButton.isHidden = false
        } else {
            evolveButton.isHidden = true
        }
    }
    private func loadPokemonImage() {
        // Load Pokemon sprite using NetworkService (consistent with other views)
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
    func evolveTapped() {
        // Evolve the Pokemon directly
        Task {
            do {
                var evolvedPokemon = playerPokemon
                try await evolutionService.evolvePokemon(&evolvedPokemon)
                await MainActor.run {
                    // Update the current Pokemon
                    self.playerPokemon = evolvedPokemon
                    // Update UI to show evolution
                    self.evolutionLabel.text = " \(self.playerPokemon.name) evolved!"
                    self.evolutionLabel.isHidden = false
                    // Hide evolve button and reload Pokemon image
                    self.evolveButton.isHidden = true
                    self.loadPokemonImage()
                }
            } catch {
                await MainActor.run {
                    self.handleError(error)
                }
            }
        }
    }
    func continueTapped() {
        // Save progress and return to battle menu
        Task {
            do {
                // Save the updated player progress
                try await savePlayerProgress()
                await MainActor.run {
                    self.coordinator?.didRequestReturnToMenu()
                }
            } catch {
                await MainActor.run {
                    self.handleError(error)
                }
            }
        }
    }
    private func savePlayerProgress() async throws {
        // Only save evolution data if Pokemon evolved during victory screen
        // Experience and battle stats were already saved by MainCoordinator
        guard let playerProgress = try persistenceService.loadPlayerProgress() else {
            throw PersistenceError.loadError
        }
        // Update Pokemon evolution data if evolved
        if playerProgress.currentPokemonID != Int32(playerPokemon.currentID) {
            try persistenceService.updateEvolution(
                playerProgress,
                newPokemonID: Int32(playerPokemon.currentID),
                newPokemonName: playerPokemon.name,
                newEvolutionStage: Int32(playerPokemon.evolutionStage)
            )
        }
    }
}
