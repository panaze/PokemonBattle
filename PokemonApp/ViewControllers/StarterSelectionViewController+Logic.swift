//
//  StarterSelectionViewController+Logic.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - StarterSelectionViewController Business Logic Extension

extension StarterSelectionViewController {
    // MARK: - Data Loading Methods
    func loadStarters() {
        isLoading = true
        showLoading(true)
        hideError()
        Task {
            do {
                var loadedStarters: [StarterOption] = []
                for starterID in starterIDs {
                    let pokemon = try await pokemonRepository.fetchPokemon(id: starterID)
                    let image = try await ImageCache.shared.downloadAndCacheImage(from: pokemon.frontSpriteURL)
                    let starter = StarterOption(
                        pokemon: pokemon,
                        image: image,
                        isSelected: false
                    )
                    loadedStarters.append(starter)
                }
                await MainActor.run {
                    self.starterOptions = loadedStarters
                    self.isLoading = false
                    self.updateUI()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }
    func selectStarter(_ starter: StarterOption) async -> PlayerPokemon? {
        do {
            // Create PlayerProgress from selected starter
            _ = try persistenceService.createPlayerProgress(
                starterID: Int32(starter.pokemon.id),
                pokemonName: starter.pokemon.name
            )
            // Create PlayerPokemon from selected starter
            let playerPokemon = PlayerPokemon(
                baseID: starter.pokemon.id,
                currentID: starter.pokemon.id,
                name: starter.pokemon.name,
                primaryType: starter.pokemon.primaryType,
                level: 5,
                experience: 0,
                evolutionStage: 0,
                frontSpriteURL: starter.pokemon.frontSpriteURL,
                backSpriteURL: starter.pokemon.backSpriteURL,
                currentHP: 100
            )
            return playerPokemon
        } catch {
            await MainActor.run {
                handleError(error)
            }
            return nil
        }
    }
    // MARK: - Initial Data Setup
    func setupInitialStarters() {
        // Create placeholder starters with default data
        starterOptions = [
            StarterOption(
                pokemon: Pokemon(
                    id: 1,
                    name: "Bulbasaur",
                    primaryType: "grass",
                    frontSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
                    backSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png"
                ),
                image: nil,
                isSelected: false
            ),
            StarterOption(
                pokemon: Pokemon(
                    id: 4,
                    name: "Charmander",
                    primaryType: "fire",
                    frontSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png",
                    backSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/4.png"
                ),
                image: nil,
                isSelected: false
            ),
            StarterOption(
                pokemon: Pokemon(
                    id: 7,
                    name: "Squirtle",
                    primaryType: "water",
                    frontSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png",
                    backSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/7.png"
                ),
                image: nil,
                isSelected: false
            )
        ]
    }}
