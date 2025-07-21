import UIKit

// MARK: - Battle Outcome Enum

// Represents the outcome of a battle for navigation purposes
enum BattleOutcome {
    case victory(player: PlayerPokemon, experienceGained: Int)
    case defeat(player: PlayerPokemon)
}

// MARK: - Navigation Delegate Protocol

// Protocol for handling navigation events from view controllers
protocol NavigationDelegate: AnyObject {
    func didSelectStarter(_ pokemon: PlayerPokemon)
    func didCompleteBattle(result: BattleOutcome)
    func didRequestReturnToMenu()
}

// MARK: - Main Coordinator Implementation

// Main coordinator responsible for app-wide navigation and flow control
class MainCoordinator {
    // MARK: - Properties
    var navigationController: UINavigationController
    private let persistenceService = PersistenceService.shared
    private let evolutionService: EvolutionService
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        let pokemonRepository = PokemonRepository()
        self.evolutionService = EvolutionService(pokemonRepository: pokemonRepository)
    }
    // MARK: - Coordinator Protocol
    func start() {
        // Check if user has an existing game
        if persistenceService.hasExistingGame() {
            // Load existing player data and go to battle menu
            loadExistingGameAndShowBattleMenu()
        } else {
            // Show starter selection for new game
            showStarterSelection()
        }
    }
    func finish() {
        // Clean up any resources if needed
    }
    // MARK: - Navigation Methods
    func showStarterSelection() {
        let starterSelectionVC = StarterSelectionViewController()
        starterSelectionVC.coordinator = self
        navigationController.setViewControllers([starterSelectionVC], animated: false)
    }
    func showBattleMenu(with playerPokemon: PlayerPokemon) {
        let battleMenuVC = BattleMenuViewController(playerPokemon: playerPokemon)
        battleMenuVC.coordinator = self
        navigationController.setViewControllers([battleMenuVC], animated: true)
    }
    func showBattle(player: PlayerPokemon, opponent: OpponentPokemon) {
        let battleVC = BattleViewController(
            playerPokemon: player,
            opponentPokemon: opponent,
            coordinator: self
        )
        navigationController.pushViewController(battleVC, animated: true)
    }
    func showVictoryScreen(player: PlayerPokemon, gainedExperience: Int, levelUpResult: LevelUpResult? = nil) {
        let victoryVC = VictoryViewController(
            playerPokemon: player,
            experienceGained: gainedExperience,
            levelUpResult: levelUpResult
        )
        victoryVC.coordinator = self
        navigationController.pushViewController(victoryVC, animated: true)
    }
    func showDefeatScreen(player: PlayerPokemon) {
        let defeatVC = DefeatViewController(playerPokemon: player)
        defeatVC.coordinator = self
        navigationController.pushViewController(defeatVC, animated: true)
    }
    func returnToBattleMenu() {
        // Always reload the battle menu with fresh data from Core Data
        // This ensures Pokemon evolution and experience updates are reflected
        do {
            guard let playerProgress = try persistenceService.loadPlayerProgress() else {
                // No existing game found, show starter selection
                showStarterSelection()
                return
            }
            // Convert PlayerProgress to PlayerPokemon with updated data
            let updatedPlayerPokemon = PlayerPokemon(
                baseID: Int(playerProgress.chosenStarterID),
                currentID: Int(playerProgress.currentPokemonID),
                name: playerProgress.pokemonName ?? "Unknown",
                primaryType: determinePrimaryType(for: Int(playerProgress.currentPokemonID)),
                level: Int(playerProgress.level),
                experience: Int(playerProgress.experience),
                evolutionStage: Int(playerProgress.evolutionStage),
                frontSpriteURL: generateSpriteURL(for: Int(playerProgress.currentPokemonID), isFront: true),
                backSpriteURL: generateSpriteURL(for: Int(playerProgress.currentPokemonID), isFront: false),
                currentHP: calculateMaxHP(for: Int(playerProgress.level))
            )
            // Check if there's an existing battle menu to update
            if let battleMenuVC = navigationController.viewControllers.first(
                where: { $0 is BattleMenuViewController })
                as? BattleMenuViewController {
                battleMenuVC.updatePlayerPokemon(updatedPlayerPokemon)
                navigationController.popToViewController(battleMenuVC, animated: true)
            } else {
                // Create a new battle menu with fresh data
                showBattleMenu(with: updatedPlayerPokemon)
            }
        } catch {
            // Error loading game data, show error and fallback to starter selection
            handleError(error)
            showStarterSelection()
        }
    }
    // MARK: - Private Helper Methods
    private func loadExistingGameAndShowBattleMenu() {
        do {
            guard let playerProgress = try persistenceService.loadPlayerProgress() else {
                // No existing game found, show starter selection
                showStarterSelection()
                return
            }
            // Convert PlayerProgress to PlayerPokemon
            let playerPokemon = PlayerPokemon(
                baseID: Int(playerProgress.chosenStarterID),
                currentID: Int(playerProgress.currentPokemonID),
                name: playerProgress.pokemonName ?? "Unknown",
                primaryType: determinePrimaryType(for: Int(playerProgress.currentPokemonID)),
                level: Int(playerProgress.level),
                experience: Int(playerProgress.experience),
                evolutionStage: Int(playerProgress.evolutionStage),
                frontSpriteURL: generateSpriteURL(for: Int(playerProgress.currentPokemonID), isFront: true),
                backSpriteURL: generateSpriteURL(for: Int(playerProgress.currentPokemonID), isFront: false),
                currentHP: calculateMaxHP(for: Int(playerProgress.level))
            )
            showBattleMenu(with: playerPokemon)
        } catch {
            // Error loading game, show starter selection
            handleError(error)
            showStarterSelection()
        }
    }
    private func determinePrimaryType(for pokemonID: Int) -> String {
        // Simple mapping for starter evolutions
        switch pokemonID {
        case 1, 2, 3: return "grass"
        case 4, 5, 6: return "fire"
        case 7, 8, 9: return "water"
        default: return "normal"
        }
    }
    private func generateSpriteURL(for pokemonID: Int, isFront: Bool) -> String {
        if isFront {
            return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonID).png"
        } else {
            return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/\(pokemonID).png"
        }
    }
    private func calculateMaxHP(for level: Int) -> Int {
        return 100 + ((level - 5) * 10)
    }
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.navigationController.present(alert, animated: true)
        }
    }
}

// MARK: - Navigation Delegate Implementation

extension MainCoordinator: NavigationDelegate {
    func didSelectStarter(_ pokemon: PlayerPokemon) {
        // Save the starter selection and navigate to battle menu
        do {
            let playerProgress = PlayerProgress(context: PersistenceController.shared.container.viewContext)
            playerProgress.chosenStarterID = Int32(pokemon.baseID)
            playerProgress.currentPokemonID = Int32(pokemon.currentID)
            playerProgress.pokemonName = pokemon.name
            playerProgress.level = Int32(pokemon.level)
            playerProgress.experience = Int32(pokemon.experience)
            playerProgress.evolutionStage = Int32(pokemon.evolutionStage)
            playerProgress.totalBattles = 0
            playerProgress.victories = 0
            playerProgress.createdAt = Date()
            playerProgress.lastPlayedAt = Date()
            try persistenceService.savePlayerProgress(playerProgress)
            showBattleMenu(with: pokemon)
        } catch {
            handleError(error)
        }
    }
    func didCompleteBattle(result: BattleOutcome) {
        switch result {
        case .victory(var player, let experienceGained):
            // Add experience and check for level up/evolution
            let levelUpResult = evolutionService.addExperience(experienceGained, to: &player)
            // Save the updated player progress to Core Data
            do {
                guard let playerProgress = try persistenceService.loadPlayerProgress() else {
                    handleError(PersistenceError.loadError)
                    return
                }
                // Update Core Data with new experience and level
                playerProgress.experience = Int32(player.experience)
                playerProgress.level = Int32(player.level)
                playerProgress.victories += 1
                playerProgress.totalBattles += 1
                playerProgress.lastPlayedAt = Date()
                try persistenceService.savePlayerProgress(playerProgress)
            } catch {
                handleError(error)
                return
            }
            // Show victory screen directly
            showVictoryScreen(player: player, gainedExperience: experienceGained, levelUpResult: levelUpResult)
        case .defeat(let player):
            // Update battle statistics for defeats too
            do {
                guard let playerProgress = try persistenceService.loadPlayerProgress() else {
                    handleError(PersistenceError.loadError)
                    return
                }
                playerProgress.totalBattles += 1
                playerProgress.lastPlayedAt = Date()
                try persistenceService.savePlayerProgress(playerProgress)
            } catch {
                handleError(error)
            }
            showDefeatScreen(player: player)
        }
    }
    func didRequestReturnToMenu() {
        returnToBattleMenu()
    }
}
