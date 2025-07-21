//
//  BattleView.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import SwiftUI

// MARK: - Battle View

// SwiftUI view for the Pokemon battle screen
struct BattleView: View {

    // MARK: - Properties

    @StateObject var viewModel: BattleViewModel
    @State private var screenShake: CGFloat = 0

    // MARK: - Initialization

    init(viewModel: BattleViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Image("BattleBackground")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.8)
                VStack(spacing: 20) {
                    // Battle Arena
                    battleArenaView(geometry: geometry)
                    // Battle Message
                    battleMessageView
                    // Move Buttons
                    moveButtonsView
                }
                .padding()
                // Damage Animation Overlay
                if viewModel.showDamageAnimation {
                    damageAnimationView
                }
            }
        }
        .offset(x: screenShake)
        .onChange(of: viewModel.showCriticalHit) { _, showCritical in
            if showCritical {
                withAnimation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)) {
                    screenShake = 5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    screenShake = 0
                }
            }
        }
    }
}

// MARK: - Preview

struct BattleView_Previews: PreviewProvider {
    static var previews: some View {
        let playerPokemon = PlayerPokemon(
            baseID: 4,
            currentID: 4,
            name: "Charmander",
            primaryType: "fire",
            level: 5,
            experience: 0,
            evolutionStage: 0,
            frontSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png",
            backSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/4.png",
            currentHP: 110
        )
        let opponentPokemon = OpponentPokemon(
            id: 25,
            name: "Pikachu",
            primaryType: "electric",
            frontSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
            backSpriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/25.png",
            level: 5
        )
        let viewModel = BattleViewModel(
            playerPokemon: playerPokemon,
            opponentPokemon: opponentPokemon,
            battleService: BattleService(),
            evolutionService: EvolutionService(pokemonRepository: PokemonRepository()),
            persistenceService: PersistenceService.shared
        )
        BattleView(viewModel: viewModel)
    }
}
