//
//  PersistanceController.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation
import CoreData

// MARK: - Persistence Controller

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Create sample data for previews
        let sampleProgress = PlayerProgress(context: context)
        sampleProgress.chosenStarterID = 1
        sampleProgress.currentPokemonID = 1
        sampleProgress.pokemonName = "Bulbasaur"
        sampleProgress.level = 5
        sampleProgress.experience = 0
        sampleProgress.evolutionStage = 0
        sampleProgress.totalBattles = 0
        sampleProgress.victories = 0
        sampleProgress.createdAt = Date()
        sampleProgress.lastPlayedAt = Date()
        do {
            try context.save()
        } catch {
            print("Failed to save preview data: \(error)")
        }
        return controller
    }()
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PokemonApp")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        /// Auto-merge background context changes to keep UI data updated
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    /// Save the current context if there are changes
    func save() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
