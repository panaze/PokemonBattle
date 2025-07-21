//
//  BattleView+Sprites.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import SwiftUI

// MARK: - Pokemon Sprite Components

extension BattleView {

    var playerPokemonSprite: some View {
        AsyncImage(url: URL(string: viewModel.battle.playerPokemon.backSpriteURL)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                playerPokemonFallbackSprite
            case .empty:
                pokemonLoadingView
            @unknown default:
                pokemonPlaceholderView
            }
        }
        .frame(width: 120, height: 120)
    }
    var playerPokemonFallbackSprite: some View {
        AsyncImage(url: URL(string: viewModel.battle.playerPokemon.frontSpriteURL)) { fallbackPhase in
            switch fallbackPhase {
            case .success(let fallbackImage):
                fallbackImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                pokemonErrorView(name: viewModel.battle.playerPokemon.name)
            case .empty:
                pokemonLoadingView
            @unknown default:
                pokemonPlaceholderView
            }
        }
    }
    var enemyPokemonSprite: some View {
        AsyncImage(url: URL(string: viewModel.battle.enemyPokemon.frontSpriteURL)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                pokemonErrorView(name: viewModel.battle.enemyPokemon.name)
            case .empty:
                pokemonLoadingView
            @unknown default:
                pokemonPlaceholderView
            }
        }
        .frame(width: 120, height: 120)
    }
    func pokemonErrorView(name: String) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                VStack {
                    Image(systemName: "questionmark.circle")
                        .font(.title)
                    Text(name)
                        .font(.caption)
                }
                .foregroundColor(.gray)
            )
    }
    var pokemonLoadingView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(ProgressView())
    }
    var pokemonPlaceholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
    }}
