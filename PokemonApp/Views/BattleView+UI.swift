//
//  BattleView+UI.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import SwiftUI

// MARK: - UI Components

extension BattleView {
    // MARK: - HP Bar View
    func hpBarView(currentHP: Int, maxHP: Int, percentage: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("HP")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Text("\(currentHP)/\(maxHP)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    // HP bar
                    Rectangle()
                        .fill(hpBarColor(percentage: percentage))
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 1.0), value: percentage)
                }
            }
            .frame(height: 8)
        }
    }
    func hpBarColor(percentage: Double) -> Color {
        if percentage > 0.5 {
            return .green
        } else if percentage > 0.25 {
            return .yellow
        } else {
            return .red
        }
    }
    // MARK: - Battle Message View
    var battleMessageView: some View {
        Text(viewModel.battleMessage)
            .font(.body)
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.8))
            )
            .foregroundColor(.white)
            .animation(.easeInOut(duration: 0.3), value: viewModel.battleMessage)
    }
    // MARK: - Damage Animation View
    var damageAnimationView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    if viewModel.showCriticalHit {
                        Text("CRITICAL HIT!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .scaleEffect(1.2)
                            .animation(
                                .easeInOut(duration: 0.3)
                                .repeatCount(3, autoreverses: true),
                                value: viewModel.showCriticalHit)
                    }
                    Text("-\(viewModel.damageAmount)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .scaleEffect(1.5)
                        .opacity(0.9)
                        .animation(.easeOut(duration: 0.5), value: viewModel.showDamageAnimation)
                }
                Spacer()
            }
            Spacer()
        }
        .transition(.scale.combined(with: .opacity))
    }
}
