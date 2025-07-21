//
//  BattleView+Components.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import SwiftUI

// MARK: - Battle Arena Components

extension BattleView {
    // MARK: - Battle Arena View
    func battleArenaView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            enemyPokemonSection(geometry: geometry)
            pokemonSpritesSection
            playerPokemonSection(geometry: geometry)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
                .shadow(radius: 5)
        )
    }
    func enemyPokemonSection(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(viewModel.battle.enemyPokemon.name)
                    .font(.headline)
                    .fontWeight(.bold)
                hpBarView(
                    currentHP: viewModel.battle.enemyPokemon.currentHP,
                    maxHP: viewModel.battle.enemyPokemon.maxHP,
                    percentage: viewModel.enemyHPPercentage,
                    color: .red
                )
            }
            .frame(width: geometry.size.width * 0.4)
        }
    }
    var pokemonSpritesSection: some View {
        HStack {
            playerPokemonSprite
            Spacer()
            Text("VS")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
            enemyPokemonSprite
        }
    }
    func playerPokemonSection(geometry: GeometryProxy) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(viewModel.battle.playerPokemon.name) (Lv.\(viewModel.battle.playerPokemon.level))")
                    .font(.headline)
                    .fontWeight(.bold)
                hpBarView(
                    currentHP: viewModel.battle.playerPokemon.currentHP,
                    maxHP: viewModel.battle.playerPokemon.maxHP,
                    percentage: viewModel.playerHPPercentage,
                    color: .green
                )
            }
            .frame(width: geometry.size.width * 0.4)
            Spacer()
        }
    }}
