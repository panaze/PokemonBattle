//
//  PokemonRepositoery.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation

class PokemonRepository {
    // MARK: - Properties
    private let networkService: NetworkService
    private let imageCache: ImageCache
    private var pokemonCache: [Int: Pokemon] = [:]
    private let cacheQueue = DispatchQueue(label: "com.pokemonapp.pokemoncache", qos: .utility)
    // MARK: - Initialization
    init() {
        self.networkService = NetworkService.shared
        self.imageCache = ImageCache.shared
    }
    // MARK: - Public Methods
    /// Fetches Pokemon data by ID with caching
    /// - Parameter id: Pokemon ID to fetch
    /// - Returns: Pokemon data
    /// - Throws: NetworkError if fetch fails
    func fetchPokemon(id: Int) async throws -> Pokemon {
        // Check cache first
        if let cachedPokemon = getCachedPokemon(id: id) {
            // Start background API call to refresh cache
            Task {
                await refreshPokemonInBackground(id: id)
            }
            return cachedPokemon
        }
        // Fetch from API
        let pokemon = try await fetchPokemonFromAPI(id: id)
        // Cache de result
        await cachePokemon(pokemon)
        return pokemon
    }
    /// Generates and fetches a random opponent with weighted distribution
    /// - Returns: Random opponent Pokemon
    /// - Throws: NetworkError if fetch fails
    func fetchRandomOpponent() async throws -> Pokemon {
        let opponentID = Int.random(in: 1...151)
        let pokemon = try await fetchPokemon(id: opponentID)
        return pokemon
    }
    /// Retrieves cached Pokemon if available
    /// - Parameter id: Pokemon ID
    /// - Returns: Cached Pokemon or nil
    func getCachedPokemon(id: Int) -> Pokemon? {
        return cacheQueue.sync {
            return pokemonCache[id]
        }
    }
    /// Creates an OpponentPokemon from a regular Pokemon
    /// - Parameter pokemon: Base Pokemon data
    /// - Returns: OpponentPokemon with battle capabilities
    func createOpponentPokemon(from pokemon: Pokemon) -> OpponentPokemon {
        // Generate a random level between 3-7 for opponent
        let randomLevel = Int.random(in: 3...7)
        return OpponentPokemon(
            id: pokemon.id,
            name: pokemon.name,
            primaryType: pokemon.primaryType,
            frontSpriteURL: pokemon.frontSpriteURL,
            backSpriteURL: pokemon.backSpriteURL,
            level: randomLevel
        )
    }
    /// Preloads Pokemon sprites for better performance
    /// - Parameter pokemon: Pokemon whose sprites to preload
    func preloadSprites(for pokemon: Pokemon) async {
        // Preload front sprite
        if !pokemon.frontSpriteURL.isEmpty {
            _ = try? await imageCache.downloadAndCacheImage(from: pokemon.frontSpriteURL)
        }
        // Preload back sprite
        if !pokemon.backSpriteURL.isEmpty {
            _ = try? await imageCache.downloadAndCacheImage(from: pokemon.backSpriteURL)
        }
    }
    /// Clears all cached Pokemon data
    func clearCache() {
        cacheQueue.sync {
            pokemonCache.removeAll()
        }
    }
    /// Gets current cache size for debugging
    var cacheSize: Int {
        return cacheQueue.sync {
            return pokemonCache.count
        }
    }
    /// Fetches Pokemon data from API and converts to Pokemon model
    /// - Parameter id: Pokemon ID
    /// - Returns: Pokemon model
    /// - Throws: NetworkError if fetch fails
    private func fetchPokemonFromAPI(id: Int) async throws -> Pokemon {
        let apiResponse = try await networkService.fetchPokemonData(id: id)
        return convertAPIResponseToPokemon(apiResponse)
    }
    /// Converts API response to Pokemon model
    /// - Parameter response: PokemonAPIResponse from API
    /// - Returns: Pokemon model
    private func convertAPIResponseToPokemon(_ response: PokemonAPIResponse) -> Pokemon {
        let primaryType = response.types.first?.type.name ?? "normal"
        let frontSpriteURL = response.sprites.frontDefault ?? ""
        let backSpriteURL = response.sprites.backDefault ?? ""
        return Pokemon(
            id: response.id,
            name: response.name.capitalized,
            primaryType: primaryType,
            frontSpriteURL: frontSpriteURL,
            backSpriteURL: backSpriteURL
        )
    }
    /// Caches Pokemon data thread-safely
    /// - Parameter pokemon: Pokemon to cache
    private func cachePokemon(_ pokemon: Pokemon) async {
        cacheQueue.sync {
            pokemonCache[pokemon.id] = pokemon
        }
        // Preload sprites in background
        Task {
            await preloadSprites(for: pokemon)
        }
    }
    /// Refreshes Pokemon data in background without blocking
    /// - Parameter id: Pokemon ID to refresh
    private func refreshPokemonInBackground(id: Int) async {
        do {
            let freshPokemon = try await fetchPokemon(id: id)
            await cachePokemon(freshPokemon)
        } catch {
            print("Background refresh failed for Pokemon \(id): \(error)")
        }
    }
}
