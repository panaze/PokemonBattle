//
//  BattleView+Moves.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import SwiftUI

// MARK: - Move Button Components

extension BattleView {
    // MARK: - Move Buttons View
    var moveButtonsView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            ForEach(viewModel.battle.playerPokemon.moves, id: \.name) { move in
                moveButton(for: move)
            }
        }
        .disabled(viewModel.isProcessingTurn || !viewModel.isPlayerTurn)
        .opacity(viewModel.isProcessingTurn || !viewModel.isPlayerTurn ? 0.6 : 1.0)
    }
    func moveButton(for move: Move) -> some View {
        Button(
            action: {
                viewModel.executePlayerMove(move)
            },
            label: {
                VStack(spacing: 4) {
                    Text(move.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    if move.isSpecial && move.name == "Rest" {
                        Text("Special Move")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    } else if move.isSpecial {
                        Text("Special")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    } else {
                        Text("Power: \(move.power)")
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(moveButtonColor(for: move))
                        .shadow(radius: 3)
                )
                .foregroundColor(.white)
            }
        )
        .disabled(move.name == "Rest" && viewModel.battle.playerUsedRest)
        .opacity(move.name == "Rest" && viewModel.battle.playerUsedRest ? 0.5 : 1.0)
    }
    func moveButtonColor(for move: Move) -> Color {
        switch move.type.lowercased() {
        case "fire":
            return .red
        case "water":
            return .blue
        case "grass":
            return .green
        case "electric":
            return .yellow
        case "normal":
            return .gray
        default:
            return .purple
        }
    }}
