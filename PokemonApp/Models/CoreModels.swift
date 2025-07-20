//
//  CoreModels.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 17/07/25.
//

import Foundation

// MARK: - Core Data Models

/// Represents the move that a Pokemon can use in a Battle
struct Move {
    let name: String
    let power: Int
    let type: String
    let description: String
    let isSpecial: Bool // For Rest move
}

/// Represents the basic Pokemon information
struct Pokemon: Pokemonable, Codable {
    let id: Int
    let name: String
    let primaryType: String
    let frontSpriteURL: String
    let backSpriteURL: String
    var moves: [Move] {
        return MoveGenerator.generateMoves(for: primaryType)
    }
}

/// Represents the Player's Pokemon in the app
struct PlayerPokemon: Pokemonable, Battler, Evolvable {
    let baseID: Int
    var currentID: Int
    var name: String
    let primaryType: String
    var level: Int
    var experience: Int
    var evolutionStage: Int
    var frontSpriteURL: String
    var backSpriteURL: String
    // Pokemonable Conformance
    var id: Int { return currentID }
    // Battler Conformance
    var currentHP: Int
    var maxHP: Int { return 100 + (level - 5) * 10}
    var isDefeated: Bool { return currentHP <= 0}
    // Evolvable Conformance
    var canEvolve: Bool {
        switch evolutionStage {
        case 0: return level >= 8
        case 1: return level >= 16
        default: return false
        }
    }
    var nextEvolutionID: Int? {
        return EvolutionData.evolutions[currentID]
    }
    var moves: [Move] {
        return MoveGenerator.generateMoves(for: primaryType)
    }
}

/// Represents enemy Pokemon that is in Battle
struct OpponentPokemon: Pokemonable, Battler {
    let id: Int
    let name: String
    let primaryType: String
    let frontSpriteURL: String
    let backSpriteURL: String
    let level: Int
    // Battler Conformance
    var currentHP: Int = 100
    var maxHP: Int = 100
    var isDefeated: Bool { return currentHP <= 0 }
    var moves: [Move] {
        return MoveGenerator.generateMoves(for: primaryType)
    }
}

// MARK: - Battle System Models

/// Represents the current state of the battle
struct Battle {
    var playerPokemon: PlayerPokemon
    var enemyPokemon: OpponentPokemon
    var currentPhase: BattlePhase
    var turnCount: Int
    var playerUsedRest: Bool
    var battleLog: [BattleEvent]
}

/// Represents the various phases of a Battle
enum BattlePhase {
    case playerTurn
    case enemyTurn
    case victory
    case defeat
}

/// Represents the result of a Battle
struct BattleResult {
    let damage: Int
    let isCritical: Bool
    let newPhase: BattlePhase
    let message: String
}

/// Represents the events that occur in a Battle
struct BattleEvent {
    let turn: Int
    let actor: BattleActor
    let move: Move
    let damage: Int
    let isCritical: Bool
    let timestamp: Date
}

/// Represents the actor in turn (player or enemy)
enum BattleActor {
    case player
    case enemy
}

// MARK: - Evolution Models

/// Represents the information about a Pokemon Evolution
struct EvolutionInfo {
    let newID: Int
    let newName: String
    let newStage: Int
}

/// Represents the result of adding experience after a Battle that can lead to a level up
struct LevelUpResult {
    let experienceGained: Int
    let oldLevel: Int
    let newLevel: Int
    let leveledUp: Bool
    let canEvolve: Bool
}

/// Represents the evolution data mapping for the Players Pokemon starters
struct EvolutionData {
    static let evolutions: [Int: Int] = [
        // Bulbasur Line
        1: 2, // Bulbasur to Ivysaur
        2: 3, // Ivysaur to Venusaur
        // Charmander Line
        4: 5, // Charmander to Charmeleon
        5: 6, // Charmeleon to Charizard
        // Squirtle Line
        7: 8, // Squirtle to Wartortle
        8: 9  // Wartortle to Blastoise
    ]
}

// MARK: - Network Models

/// Represents type slot information from the PokeAPI Response
struct PokemonTypeSlot: Codable {
    let slot: Int
    let type: PokemonType
}

/// Represents the type information from the PokeAPI Response
struct PokemonType: Codable {
    let name: String
}

/// Represents the Sprite URLs from the PokeAPI  Response
struct PokemonSprites: Codable {
    let frontDefault: String?
    let backDefault: String?
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case backDefault = "back_default"
    }
}

/// Represents the main model for PokeAPI Response
struct PokemonAPIResponse: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeSlot]
    let sprites: PokemonSprites
}
