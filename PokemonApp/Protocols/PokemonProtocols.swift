//
//  PokemonProtocols.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 17/07/25.
//

import Foundation

// MARK: - Core Pokemon Protocols

/// Protocol that defines the main structure of what makes a Pokemon
protocol Pokemonable {
    var id: Int { get }
    var name: String { get }
    var primaryType: String { get }
    var frontSpriteURL: String { get }
    var backSpriteURL: String { get }
    var moves: [Move] { get }
}

/// Protocol that makes a Pokemon set for Battle
protocol Battler {
    var currentHP: Int { get }
    var maxHP: Int { get }
    var isDefeated: Bool { get }
}

/// Protocol for Pokemons that can evolve (Player Pokemons)
protocol Evolvable {
    var evolutionStage: Int { get }
    var canEvolve: Bool { get }
    var nextEvolutionID: Int? { get }
}
