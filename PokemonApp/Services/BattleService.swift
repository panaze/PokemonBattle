//
//  BattleService.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation

class BattleService {
    // MARK: - Battle Initialization
    /// Sets up initial battle state with player Pokemon and Opponent Pokemon with both full heald
    /// - Parameters:
    ///   - player: The player's Pokemon participating in battle
    ///   - opponent: The opponent's Pokemon participating in battle
    /// - Returns: A fully initializd "Battle"
    func initializeBattle(player: PlayerPokemon, opponent: OpponentPokemon) -> Battle {
        var playerPokemon = player
        var enemyPokemon = opponent
        // Make sure both pokemon start with full HP
        playerPokemon.currentHP = playerPokemon.maxHP
        enemyPokemon.currentHP = enemyPokemon.maxHP
        return Battle(
            playerPokemon: playerPokemon,
            enemyPokemon: enemyPokemon,
            currentPhase: .playerTurn,
            turnCount: 1,
            playerUsedRest: false,
            battleLog: []
        )

    }
    /// Executes player's move choice, calculate damage, and applies result to battle state.
    /// - Parameters:
    ///   - move: The move selected by the player to execute
    ///   - battle: The current battle state (modified in place)
    /// - Returns: A "Battle Result" that information about damage , critical hit status, next phase, and description
    func executePlayerMove(_ move: Move, in battle: inout Battle) -> BattleResult {
        guard battle.currentPhase == .playerTurn else {
            return BattleResult(
                damage: 0,
                isCritical: false,
                newPhase: battle.currentPhase,
                message: "Its not your turn"
            )
        }
        guard !battle.playerPokemon.isDefeated else {
            return BattleResult(
                damage: 0,
                isCritical: false,
                newPhase: .defeat,
                message: "You lost!"
            )
        }
        // Handle Rest move
        if move.isSpecial && move.name == "Rest" {
            return executeRestMove(in: &battle)
        }
        // Calculate damage and critical hit
        let isCritical = checkForCriticalHit()
        let damage = calculateDamage(move: move, isCritical: isCritical)
        // Apply damage to enemy
        battle.enemyPokemon.currentHP = max(0, battle.enemyPokemon.currentHP - damage)
        // Create battle event
        let event = BattleEvent(
            turn: battle.turnCount,
            actor: .player,
            move: move,
            damage: damage,
            isCritical: isCritical,
            timestamp: Date()
        )
        battle.battleLog.append(event)

        // Determine new Phase
        let newPhase: BattlePhase
        let message: String
        if battle.enemyPokemon.isDefeated {
            newPhase = .victory
            message = "\(battle.playerPokemon.name) defeated \(battle.enemyPokemon.name)!"
        } else {
            newPhase = .enemyTurn
            let criticalText = isCritical ? "Critical hit!" : ""
            message = "\(battle.playerPokemon.name) used \(move.name)! Dealt \(damage) damage. \(criticalText)"
        }
        battle.currentPhase = newPhase
        return BattleResult(
            damage: damage,
            isCritical: isCritical,
            newPhase: newPhase,
            message: message)
    }
    /// Executes automatic move selection for opponent's turn.
    /// - Parameter battle: The current battle state (modified in place)
    /// - Returns: A "Battle Result" with the Opponents move effects and battle progress
    func executeEnemyTurn(in battle: inout Battle) -> BattleResult {
        guard battle.currentPhase == .enemyTurn else {
            return BattleResult(
                damage: 0, isCritical: false, newPhase: battle.currentPhase, message: "It's not the enemy's turn"
            )
        }
        guard !battle.enemyPokemon.isDefeated else {
            return BattleResult( damage: 0, isCritical: false, newPhase: .victory, message: "The enemy is defeated!"
            )
        }
        // Enemys automatic move selection - random choice from available moves
        let availableMoves = battle.enemyPokemon.moves
        guard !availableMoves.isEmpty else {
            return BattleResult( damage: 0, isCritical: false, newPhase: .playerTurn, message: "Enemy has no moves"
            )
        }
        let selectedMove = availableMoves.randomElement()!
        // Calculate damage and critical hit
        let isCritical = checkForCriticalHit()
        let damage = calculateDamage(move: selectedMove, isCritical: isCritical)
        // Apply damage to player
        battle.playerPokemon.currentHP = max(0, battle.playerPokemon.currentHP - damage)
        // Create battle event
        let event = BattleEvent(
            turn: battle.turnCount,
            actor: .enemy,
            move: selectedMove,
            damage: damage,
            isCritical: isCritical,
            timestamp: Date()
        )
        battle.battleLog.append(event)
        // Increment turn count and determine new phase
        battle.turnCount += 1
        let newPhase: BattlePhase
        let message: String
        if battle.playerPokemon.isDefeated {
            newPhase = .defeat
            message = "\(battle.enemyPokemon.name) defeated \(battle.playerPokemon.name)!"
        } else {
            newPhase = .playerTurn
            let criticalText = isCritical ? " Critical hit!" : ""
            message = "\(battle.enemyPokemon.name) used \(selectedMove.name)! Dealt \(damage) damage.\(criticalText)"
        }
        battle.currentPhase = newPhase
        return BattleResult(
            damage: damage,
            isCritical: isCritical,
            newPhase: newPhase,
            message: message
        )
    }
    /// Calculates damage for a move with random bonus and ciritcal damage probability
    /// - Parameters:
    ///   - move: The move being used, containing base powe value
    ///   - isCritical: Whether is critical hit (defaults to false)
    /// - Returns: Returns calculated damage as an integer
    func calculateDamage(move: Move, isCritical: Bool = false ) -> Int {
        let baseDamage = move.power
        let randomBonus = Int.random(in: 0...10)
        let totalDamage = baseDamage + randomBonus
        return isCritical ? Int(Double(totalDamage) * 1.5) : totalDamage
    }
    /// Determines if an attack results in a critical hit.
    /// - Returns: "true" if the attack is a critical hit
    func checkForCriticalHit() -> Bool {
        return Double.random(in: 0...1) < 0.10
    }
    // MARK: Special Moves
    /// Executes the special move "Rest" that restores Pokemon health but can only be used once per Battle.
    /// - Parameter battle: The current battle state (modified in place)
    /// - Returns: A "Battle Result" with healing amount and phase transition
    private func executeRestMove(in battle: inout Battle) -> BattleResult {
        guard !battle.playerUsedRest else {
            return BattleResult(
                damage: 0,
                isCritical: false,
                newPhase: battle.currentPhase,
                message: "Rest can only be used once per battle"
                )
        }
        let healAmount = 30
        let oldHP = battle.playerPokemon.currentHP
        battle.playerPokemon.currentHP = min(battle.playerPokemon.maxHP, battle.playerPokemon.currentHP + healAmount)
        let actualHeal = battle.playerPokemon.currentHP - oldHP

        battle.playerUsedRest = true
        battle.currentPhase = .enemyTurn
        // Create battle event for Rest
        let restMove = Move(name: "Rest", power: 0, type: "normal", description: "Restore 30 HP", isSpecial: true)
        let event = BattleEvent(
            turn: battle.turnCount,
            actor: .player,
            move: restMove,
            damage: -actualHeal,
            isCritical: false,
            timestamp: Date()
        )
        battle.battleLog.append(event)
        return BattleResult(
            damage: -actualHeal,
            isCritical: false,
            newPhase: .enemyTurn,
            message: "\(battle.playerPokemon.name) used Rest. Restored \(actualHeal) HP."
        )
    }
}
