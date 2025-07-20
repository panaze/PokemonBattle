//
//  PersitanceService.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation
import CoreData

/// Service for managing player progress persistence using Core Data
class PersistenceService {
    static let shared = PersistenceService()
    private let persistenceController: PersistenceController
    private init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    /// Save player progress to Core Data
    /// - Parameter progress: The PlayerProgress Core data object to save
    /// - Throws: PersistenceError if save fails
    func savePlayerProgress(_ progress: PlayerProgress) throws {
        do {
            try persistenceController.save()
        } catch {
            throw PersistenceError.saveError
        }
    }
    /// Load player progress from Core Data
    /// - Returns: PlayerProgress object if found, nil otherwise
    /// - Throws: PersistenceError if it fails
    func loadPlayerProgress() throws -> PlayerProgress? {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<PlayerProgress> = PlayerProgress.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            throw PersistenceError.loadError
        }
    }
    /// Check if an existig game exists
    /// - Returns: Returns true if saved game exists, false otherwise
    func hasExistingGame() -> Bool {
        do {
            let progress = try loadPlayerProgress()
            return progress != nil
        } catch {
            return false
        }
    }
    /// Create a new Player
    /// - Parameters:
    ///   - starterID: The ID of the chosen starter Pokemon
    ///   - pokemonName: The name of the starter Pokemon
    /// - Returns: The created PlayerProgress object
    /// - Throws: PersisteneError if creation fails
    func createPlayerProgress(starterID: Int32, pokemonName: String) throws -> PlayerProgress {
        let context = persistenceController.container.viewContext
        let progress = PlayerProgress(context: context)
        progress.chosenStarterID = starterID
        progress.currentPokemonID = starterID
        progress.pokemonName = pokemonName
        progress.level = 5
        progress.experience = 0
        progress.evolutionStage = 0
        progress.totalBattles = 0
        progress.victories = 0
        progress.createdAt = Date()
        progress.lastPlayedAt = Date()
        do {
            try savePlayerProgress(progress)
            return progress
        } catch {
            context.delete(progress)
            throw PersistenceError.saveError
        }
    }
    /// Update player progress after a battle
    /// - Parameters:
    ///   - progress: The PlayerProgress object to update
    ///   - won: Check if the player won the battle
    ///   - experienceGained: Amount of experienced gained
    ///  - Throws: Persistence error if it fails
    func updateAfterBattle(_ progress: PlayerProgress, won: Bool, experienceGained: Int32 = 50) throws {
        progress.totalBattles += 1
        progress.lastPlayedAt = Date()
        if won {
            progress.victories += 1
            progress.experience += experienceGained
            // Check for level up (every 50 XP)
            let newLevel = 5 + (progress.experience / 50)
            if newLevel > progress.level {
                progress.level = newLevel
            }
        }
        try savePlayerProgress(progress)
    }
    /// Update Pokemon evolution data
    /// - Parameters:
    ///   - progress: The PlayerProgress object to update
    ///   - newPokemonID: The ID of evolved Pokemon
    ///   - newPokemonName: The name of the evolved Pokemon
    ///   - newEvolutionStage: The new evolution stage
    ///  - Throws: PersistanceError if  fails
    func updateEvolution(
        _ progress: PlayerProgress,
        newPokemonID: Int32,
        newPokemonName: String,
        newEvolutionStage: Int32) throws {
            progress.currentPokemonID = newPokemonID
            progress.pokemonName = newPokemonName
            progress.evolutionStage = newEvolutionStage
            progress.lastPlayedAt = Date()
            try savePlayerProgress(progress)
        }
    /// Delete all player progress
    /// - Throws: PersitenceError if  fails
    func deleteAllProgress() throws {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = PlayerProgress.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            throw PersistenceError.saveError
        }
    }
}
