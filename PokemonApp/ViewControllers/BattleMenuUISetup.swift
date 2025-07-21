//
//  BattleMenuUISetup.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - BattleMenuViewController UI Setup Extension

extension BattleMenuViewController {
    func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Battle Menu"
        setupScrollView()
        setupPlayerInfoContainer()
        setupPokemonImageView()
        setupLabels()
        setupFindOpponentButton()
        setupLoadingIndicator()
        setupConstraints()
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    func setupPlayerInfoContainer() {
        playerInfoContainerView.backgroundColor = .systemBackground
        playerInfoContainerView.layer.cornerRadius = 16
        playerInfoContainerView.layer.shadowColor = UIColor.black.cgColor
        playerInfoContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        playerInfoContainerView.layer.shadowRadius = 8
        playerInfoContainerView.layer.shadowOpacity = 0.08
        playerInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playerInfoContainerView)
    }
    func setupPokemonImageView() {
        pokemonImageView.contentMode = .scaleAspectFit
        pokemonImageView.backgroundColor = .systemGray6
        pokemonImageView.layer.cornerRadius = 12
        pokemonImageView.layer.borderWidth = 2
        pokemonImageView.layer.borderColor = UIColor.systemGray4.cgColor
        pokemonImageView.clipsToBounds = true
        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        playerInfoContainerView.addSubview(pokemonImageView)
    }
    func setupLabels() {
        // Pokemon name label
        playerNameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        playerNameLabel.textAlignment = .center
        playerNameLabel.textColor = .label
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        // Stats label - keeping original simple formatting
        playerStatsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        playerStatsLabel.textAlignment = .center
        playerStatsLabel.numberOfLines = 0
        playerStatsLabel.textColor = .secondaryLabel
        playerStatsLabel.translatesAutoresizingMaskIntoConstraints = false
        // Evolution info label
        evolutionInfoLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        evolutionInfoLabel.textAlignment = .center
        evolutionInfoLabel.textColor = .systemOrange
        evolutionInfoLabel.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        evolutionInfoLabel.layer.cornerRadius = 8
        evolutionInfoLabel.layer.masksToBounds = true
        evolutionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        playerInfoContainerView.addSubview(playerNameLabel)
        playerInfoContainerView.addSubview(playerStatsLabel)
        playerInfoContainerView.addSubview(evolutionInfoLabel)
    }
    func setupFindOpponentButton() {
        findOpponentButton.setTitle("Find Opponent", for: .normal)
        findOpponentButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        findOpponentButton.backgroundColor = .systemBlue
        findOpponentButton.setTitleColor(.white, for: .normal)
        findOpponentButton.layer.cornerRadius = 16
        findOpponentButton.layer.shadowColor = UIColor.systemBlue.cgColor
        findOpponentButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        findOpponentButton.layer.shadowRadius = 8
        findOpponentButton.layer.shadowOpacity = 0.3
        findOpponentButton.addAction(UIAction { [weak self] _ in
            self?.findOpponentTapped()
        }, for: .touchUpInside)
        findOpponentButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(findOpponentButton)
    }
    func setupLoadingIndicator() {
        loadingIndicator.style = .medium
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingIndicator)
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // Player info container constraints
            playerInfoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            playerInfoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            playerInfoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // Pokemon image constraints
            pokemonImageView.topAnchor.constraint(equalTo: playerInfoContainerView.topAnchor, constant: 24),
            pokemonImageView.centerXAnchor.constraint(equalTo: playerInfoContainerView.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 140),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 140),
            // Pokemon name label constraints
            playerNameLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 20),
            playerNameLabel.leadingAnchor.constraint(equalTo: playerInfoContainerView.leadingAnchor, constant: 24),
            playerNameLabel.trailingAnchor.constraint(equalTo: playerInfoContainerView.trailingAnchor, constant: -24),
            // Stats label constraints
            playerStatsLabel.topAnchor.constraint(equalTo: playerNameLabel.bottomAnchor, constant: 16),
            playerStatsLabel.leadingAnchor.constraint(equalTo: playerInfoContainerView.leadingAnchor, constant: 24),
            playerStatsLabel.trailingAnchor.constraint(equalTo: playerInfoContainerView.trailingAnchor, constant: -24),
            // Evolution info label constraints
            evolutionInfoLabel.topAnchor.constraint(equalTo: playerStatsLabel.bottomAnchor, constant: 16),
            evolutionInfoLabel.leadingAnchor.constraint(equalTo: playerInfoContainerView.leadingAnchor, constant: 24),
            evolutionInfoLabel.trailingAnchor.constraint(
                equalTo: playerInfoContainerView.trailingAnchor, constant: -24),
            evolutionInfoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
            evolutionInfoLabel.bottomAnchor.constraint(equalTo: playerInfoContainerView.bottomAnchor, constant: -24),
            // Find opponent button constraints
            findOpponentButton.topAnchor.constraint(equalTo: playerInfoContainerView.bottomAnchor, constant: 32),
            findOpponentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            findOpponentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            findOpponentButton.heightAnchor.constraint(equalToConstant: 56),
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: findOpponentButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: findOpponentButton.centerYAnchor),
            // Content view bottom constraint
            contentView.bottomAnchor.constraint(equalTo: findOpponentButton.bottomAnchor, constant: 32)
        ])
    }
}
