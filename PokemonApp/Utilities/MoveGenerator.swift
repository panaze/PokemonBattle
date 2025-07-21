//
//  MoveGenerator.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 17/07/25.
//

import Foundation

// MARK: - Move Generation System

/// Class that generates moves based on the type of Pokemon.
/// Used static on variables because it ensures we have only one copy in memory.

class MoveGenerator {
    // MARK: - Type-specific moves mapping
    static let typeMovesMap: [String: Move] = [
        "fire": Move(
            name: "Fire Attack",
            power: 30,
            type: "fire",
            description: "A small burst of flames",
            isSpecial: false
        ),
        "water": Move(
            name: "Water Attack",
            power: 30,
            type: "water",
            description: "A small burst of water",
            isSpecial: false
        ),
        "grass": Move(
            name: "Grass Attack",
            power: 30,
            type: "grass",
            description: "A swift vine attack",
            isSpecial: false
        ),
        "electric": Move(
            name: "Electric Attack",
            power: 90,
            type: "electric",
            description: "A bolt of lightning",
            isSpecial: true
        ),
        "psychic": Move(
            name: "Confusion Attack",
            power: 30,
            type: "psychic",
            description: "A psychic attack",
            isSpecial: false
        ),
        "poison": Move(
            name: "Poison Attack",
            power: 30,
            type: "poison",
            description: "A poisnous sting",
            isSpecial: false),
        "ground": Move(
            name: "Ground Attack",
            power: 30,
            type: "ground",
            description: "A mud shot",
            isSpecial: false),
        "rock": Move(
            name: "Rock Attack",
            power: 30,
            type: "rock",
            description: "A rock throw",
            isSpecial: false
        ),
        "bug": Move(
            name: "Bug Attack",
            power: 30,
            type: "bug",
            description: "A bug bite",
            isSpecial: false
        ),
        "ghost": Move(
            name: "Ghost Attack",
            power: 30,
            type: "ghost",
            description: "A ghostly touch",
            isSpecial: false
        ),
        "fighting": Move(
            name: "Fighting Attack",
            power: 30,
            type: "fighting",
            description: "A fierce strike",
            isSpecial: false
        ),
        "ice": Move(
            name: "Ice Attack",
            power: 30,
            type: "ice",
            description: "A freezing blast",
            isSpecial: false
        ),
        "flying": Move(
            name: "Flying Attack",
            power: 30,
            type: "flying",
            description: "A soaring strike",
            isSpecial: false
        ),
        "dragon": Move(
            name: "Dragon Attack",
            power: 30,
            type: "dragon",
            description: "A dragon's breath",
            isSpecial: false
        ),
        "normal": Move(
            name: "Normal Attack",
            power: 30,
            type: "normal",
            description: "A basic attack",
            isSpecial: false
        )
    ]
    // MARK: - Standard Moves available for all Pokemon
    static let standardMoves = [
        Move(
            name: "Tackle",
            power: 20,
            type: "normal",
            description: "A physical attack",
            isSpecial: false
        ),
        Move(
            name: "Quick Attack",
            power: 15,
            type: "normal",
            description: "A fast strike",
            isSpecial: false
        ),
        Move(
            name: "Rest",
            power: 0,
            type: "normal",
            description: "Restores 30 HP (once per battle)",
            isSpecial: true
        )
    ]
    // MARK: - Move Generation

    /// Generates a set of 4 moves for a Pokemon (1 based on its primary type)
    /// - Parameter type: The primary type of the Pokemon
    /// - Returns: Array of 4 moves (3 standard moves, 1 primary type move)
    static func generateMoves(for type: String) -> [Move] {
        let typeMove = typeMovesMap[type.lowercased()] ?? typeMovesMap["normal"]!
        return [
            standardMoves[0],
            typeMove,
            standardMoves[1],
            standardMoves[2]
        ]
    }
    /// Gets a random move from the available moves for AI opponents
    /// - Parameter moves: Array of available moves
    /// - Returns: A randomly selected move (from standard moves)
    static func getRandomMove(from moves: [Move]) -> Move {
        return moves.randomElement() ?? standardMoves[0]
    }

}
