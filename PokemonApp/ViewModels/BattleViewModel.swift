//
//  BattleViewModel.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Battle View Model

// View model managing turn-based combat state for SwiftUI battle view
@MainActor
class BattleViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var battle: Battle
    @Published var battleMessage: String = ""
    @Published var isPlayerTurn: Bool = true
    @Published var showDamageAnimation: Bool = false
    @Published var damageAmount: Int = 0
    @Published var showCriticalHit: Bool = false
    @Published var isProcessingTurn: Bool = false
    @Published var playerHPPercentage: Double = 1.0
    @Published var enemyHPPercentage: Double = 1.0

    // MARK: - Private Properties
    private let battleService: BattleService
    private let evolutionService: EvolutionService
    private let persistenceService: PersistenceService
    private var cancellables = Set<AnyCancellable>()
    // MARK: - Completion Handler
    var onBattleComplete: ((BattleOutcome) -> Void)?
    // MARK: - Initialization
    init(
        playerPokemon: PlayerPokemon,
        opponentPokemon: OpponentPokemon,
        battleService: BattleService,
        evolutionService: EvolutionService,
        persistenceService: PersistenceService
    ) {
        self.battleService = battleService
        self.evolutionService = evolutionService
        self.persistenceService = persistenceService
        // Initialize battle
        self.battle = battleService.initializeBattle(player: playerPokemon, opponent: opponentPokemon)
        // Set initial HP percentages
        self.playerHPPercentage = Double(battle.playerPokemon.currentHP) / Double(battle.playerPokemon.maxHP)
        self.enemyHPPercentage = Double(battle.enemyPokemon.currentHP) / Double(battle.enemyPokemon.maxHP)
        // Set initial battle message
        self.battleMessage = "Battle begins! \(battle.playerPokemon.name) vs \(battle.enemyPokemon.name)"
        setupObservers()
    }
    // MARK: - Private Setup
    private func setupObservers() {
        // Observe battle phase changes
        $battle
            .map { $0.currentPhase == .playerTurn }
            .assign(to: \.isPlayerTurn, on: self)
            .store(in: &cancellables)
    }
    // MARK: - Public Methods
    /// Execute a player move
    func executePlayerMove(_ move: Move) {
        guard !isProcessingTurn && battle.currentPhase == .playerTurn else { return }
        isProcessingTurn = true
        Task {
            // Execute player move
            let result = battleService.executePlayerMove(move, in: &battle)
            // Update UI with result
            await updateUIWithBattleResult(result, isPlayerMove: true)
            // Check for battle end
            if battle.currentPhase == .victory || battle.currentPhase == .defeat {
                await handleBattleEnd()
                return
            }
            // Execute enemy turn after delay
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 second delay
            if battle.currentPhase == .enemyTurn {
                let enemyResult = battleService.executeEnemyTurn(in: &battle)
                await updateUIWithBattleResult(enemyResult, isPlayerMove: false)
                // Check for battle end after enemy turn
                if battle.currentPhase == .victory || battle.currentPhase == .defeat {
                    await handleBattleEnd()
                }
            }
            isProcessingTurn = false
        }
    }
    // MARK: - Private Methods
    private func updateUIWithBattleResult(_ result: BattleResult, isPlayerMove: Bool) async {
        // Update battle message
        battleMessage = result.message
        // Show damage animation if damage was dealt
        if result.damage > 0 {
            damageAmount = result.damage
            showDamageAnimation = true
            showCriticalHit = result.isCritical
            // Animate HP bars
            await animateHPChange(isPlayerMove: isPlayerMove)
            // Hide damage animation after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            showDamageAnimation = false
            showCriticalHit = false
        } else if result.damage < 0 {
            // Healing (Rest move) - always updates player HP
            await animateHPChange(isPlayerMove: false)
        }
    }
    private func animateHPChange(isPlayerMove: Bool) async {
        withAnimation(.easeInOut(duration: 1.0)) {
            if isPlayerMove {
                // Player attacked enemy, update enemy HP
                enemyHPPercentage = Double(battle.enemyPokemon.currentHP) / Double(battle.enemyPokemon.maxHP)
            } else {
                // Enemy attacked player, update player HP
                playerHPPercentage = Double(battle.playerPokemon.currentHP) / Double(battle.playerPokemon.maxHP)
            }
        }
    }
    private func handleBattleEnd() async {
        let outcome: BattleOutcome
        if battle.currentPhase == .victory {
            let experienceGained = 50
            outcome = .victory(player: battle.playerPokemon, experienceGained: experienceGained)
        } else {
            outcome = .defeat(player: battle.playerPokemon)
        }
        // Delay before calling completion handler
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        onBattleComplete?(outcome)
    }

}
