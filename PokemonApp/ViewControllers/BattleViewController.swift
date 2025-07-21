//
//  BattleViewController.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit
import SwiftUI

// MARK: - Battle View Controller

/// View controller for the actual Pokemon battle screen using SwiftUI with UIKit bridge
class BattleViewController: UIViewController {
    // MARK: - Properties
    private let playerPokemon: PlayerPokemon
    private let opponentPokemon: OpponentPokemon
    private weak var coordinator: MainCoordinator?
    // MARK: - SwiftUI Integration
    private var battleViewModel: BattleViewModel!
    private var hostingController: UIHostingController<BattleView>!
    // MARK: - Initialization
    init(playerPokemon: PlayerPokemon, opponentPokemon: OpponentPokemon, coordinator: MainCoordinator?) {
        self.playerPokemon = playerPokemon
        self.opponentPokemon = opponentPokemon
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIBattle()
    }
    // MARK: - Private Methods
    private func setupSwiftUIBattle() {
        view.backgroundColor = .systemBackground
        title = "Battle"
        // Create simple service instances
        let battleService = BattleService()
        let evolutionService = EvolutionService(pokemonRepository: PokemonRepository())
        let persistenceService = PersistenceService.shared
        // Create battle view model with dependencies
        battleViewModel = BattleViewModel(
            playerPokemon: playerPokemon,
            opponentPokemon: opponentPokemon,
            battleService: battleService,
            evolutionService: evolutionService,
            persistenceService: persistenceService
        )
        // Set up battle completion handler
        battleViewModel.onBattleComplete = { [weak self] outcome in
            Task { @MainActor in
                self?.handleBattleResult(outcome)
            }
        }
        // Create SwiftUI view
        let battleView = BattleView(viewModel: battleViewModel)
        // Create hosting controller
        hostingController = UIHostingController(rootView: battleView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        // Set up constraints
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func handleBattleResult(_ result: BattleOutcome) {
        coordinator?.didCompleteBattle(result: result)
    }
}
