//
//  EvolutionService.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation

class EvolutionService {

    private let pokemonRepository: PokemonRepository
    // MARK: - Initialization
    init(pokemonRepository: PokemonRepository) {
        self.pokemonRepository = pokemonRepository
    }
    // MARK: - Evolution Checking
    /// Determines if Pokemon is elegible for evolution
    /// - Parameter pokemon: The Pokemon to check for evolution availability
    /// - Returns: Boolean indicating if the evolution fails or cannot evole
    func checkForEvolution(_ pokemon: PlayerPokemon) -> Bool {
        return pokemon.canEvolve && pokemon.nextEvolutionID != nil
    }
    // MARK: - Evolution Execution
    /// Evolve Pokemon to its next evolution
    /// - Parameter pokemon: The Pokemon to evolve (by reference)
    ///  - Throws: EvolutionError if evolution fails or cannot evolve
    func evolvePokemon(_ pokemon: inout PlayerPokemon) async throws {
        guard checkForEvolution(pokemon) else {
            throw EvolutionError.cannotEvolve
        }
        guard let evolutionInfo = getEvolutionData(for: pokemon.currentID)else {
            throw EvolutionError.noEvolutionData
        }
        do {
            // Fetch evolved Pokemon data from repository
            let evolvedPokemon = try await pokemonRepository.fetchPokemon(id: evolutionInfo.newID)
            // Update Pokemon with evolution data
            pokemon.currentID = evolutionInfo.newID
            pokemon.name = evolvedPokemon.name
            pokemon.evolutionStage = evolutionInfo.newStage
            pokemon.frontSpriteURL = evolvedPokemon.frontSpriteURL
            pokemon.backSpriteURL = evolvedPokemon.backSpriteURL
        } catch {
            throw EvolutionError.fetchFailed(error)
        }
    }
    // MARK: Evolution Data
    /// Retrieves evolution information for a specific Pokemon ID
    /// - Parameter pokemonID: he ID of the Pokemon to get evolution data for
    /// - Returns: EvolutionInfo object containing evolution details, or nil if no evolution exists
    func getEvolutionData(for pokemonID: Int) -> EvolutionInfo? {
        guard let nextID = EvolutionData.evolutions[pokemonID] else {
            return nil
        }
        // Determine evolution stage and name based on ID
        let (newName, newStage) = getEvolutionDetails(for: nextID, from: pokemonID)
        return EvolutionInfo(
            newID: nextID,
            newName: newName,
            newStage: newStage
        )
    }
    // MARK: Experince and Level Management
    /// Adds experience to a Pokemon and handles level advancement.
    /// - Parameters:
    ///   - amount: Amount of experience points to add
    ///   - pokemon: The Pokemon to add experience to ( by reference)
    /// - Returns: LevelUpResult containing information about level changes and evolution availability
    func addExperience(_ amount: Int, to pokemon: inout PlayerPokemon) -> LevelUpResult {
        let oldLevel = pokemon.level
        pokemon.experience += amount
        // Calculate new level based on experience
        let newLevel = calculateLevel(from: pokemon.experience)
        pokemon.level = newLevel
        let leveledUp = newLevel > oldLevel
        let canEvolveNow = leveledUp && checkForEvolution(pokemon)
        return LevelUpResult(
            experienceGained: amount,
            oldLevel: oldLevel,
            newLevel: newLevel,
            leveledUp: leveledUp,
            canEvolve: canEvolveNow)
    }
    /// Calculates level based on total experience (50 XP per level after level 5)
    /// - Parameter experience: Total experience points
    /// - Returns: Calculated level based on experience
    private func calculateLevel(from experience: Int) -> Int {
        return 5 + (experience / 50)
    }
    // MARK: - Helper Methods
    ///  Maps evolution IDs to their corresponding names and evolution stages
    /// - Parameters:
    ///   - evolutionID: The ID of the evolved Pokemon
    ///   - baseID:  The ID of the base Pokemon (used for fallback calculations)
    /// - Returns: Tuple containing the evolved Pokemon's name and evolution stage
    private func getEvolutionDetails(for evolutionID: Int, from baseID: Int) -> (String, Int) {
        // New evolution IDs to names and stages
        switch evolutionID {
        // Bulbasur line
        case 2: return ("Ivysaur", 1)
        case 3: return ("Venusaur", 2)
        // Charmander Line
        case 5: return ("Charmeleon", 1)
        case 6: return ("Charizard", 2)
        // Squirtle Line
        case 8: return ("Wartortle", 1)
        case 9: return ("Blastoise", 2)
        default:
            // Fallback - try to determine stage based on current stage
            let currentStage = getCurrentStage(for: baseID)
            return ("Unknown", currentStage + 1)
        }
    }
    /// Determines the current evolution stage of a Pokemon based on its ID
    /// - Parameter pokemonID: The Pokemon's ID
    /// - Returns: Evolution stage (0 = base, 1 = second stage, 2 = final stage)
    private func getCurrentStage(for pokemonID: Int) -> Int {
        switch pokemonID {
        // Base forms
        case 1, 4, 7: return 0
        // Second stage
        case 2, 5, 8: return 1
        // Final stage
        case 3, 6, 9: return 2
        default: return 0
        }
    }
}
