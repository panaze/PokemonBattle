//
//  VictoryUISetup.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - VictoryViewController UI Setup Extension

extension VictoryViewController {
    // MARK: - UI Component Creation
    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }
    func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func createVictoryLabel() -> UILabel {
        let label = UILabel()
        label.text = "Victory!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    func createPokemonImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Set placeholder image
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        imageView.image = UIImage(systemName: "photo", withConfiguration: config)
        imageView.tintColor = .systemGray3
        return imageView
    }
    func createExperienceLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    func createLevelUpLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemBlue
        label.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    func createEvolutionLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemPurple
        label.backgroundColor = .systemPurple.withAlphaComponent(0.1)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    func createEvolveButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Evolve Now!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.systemPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addAction(UIAction { [weak self] _ in
            self?.evolveTapped()
        }, for: .touchUpInside)
        return button
    }
    func createContinueButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.systemGreen.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        // Modern closure-based action instead of @objc
        button.addAction(UIAction { [weak self] _ in
            self?.continueTapped()
        }, for: .touchUpInside)
        return button
    }
    // MARK: - Constraint Setup
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
            // Victory container constraints
            victoryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            victoryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            victoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // Victory label
            victoryLabel.topAnchor.constraint(equalTo: victoryContainer.topAnchor, constant: 24),
            victoryLabel.leadingAnchor.constraint(equalTo: victoryContainer.leadingAnchor, constant: 24),
            victoryLabel.trailingAnchor.constraint(equalTo: victoryContainer.trailingAnchor, constant: -24),
            // Pokemon image
            pokemonImageView.topAnchor.constraint(equalTo: victoryLabel.bottomAnchor, constant: 20),
            pokemonImageView.centerXAnchor.constraint(equalTo: victoryContainer.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 140),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 140),
            // Experience label
            experienceLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 20),
            experienceLabel.leadingAnchor.constraint(equalTo: victoryContainer.leadingAnchor, constant: 24),
            experienceLabel.trailingAnchor.constraint(equalTo: victoryContainer.trailingAnchor, constant: -24),
            // Level up label
            levelUpLabel.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 16),
            levelUpLabel.leadingAnchor.constraint(equalTo: victoryContainer.leadingAnchor, constant: 24),
            levelUpLabel.trailingAnchor.constraint(equalTo: victoryContainer.trailingAnchor, constant: -24),
            levelUpLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            // Evolution label
            evolutionLabel.topAnchor.constraint(equalTo: levelUpLabel.bottomAnchor, constant: 16),
            evolutionLabel.leadingAnchor.constraint(equalTo: victoryContainer.leadingAnchor, constant: 24),
            evolutionLabel.trailingAnchor.constraint(equalTo: victoryContainer.trailingAnchor, constant: -24),
            evolutionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            evolutionLabel.bottomAnchor.constraint(equalTo: victoryContainer.bottomAnchor, constant: -24),
            // Evolve button
            evolveButton.topAnchor.constraint(equalTo: victoryContainer.bottomAnchor, constant: 32),
            evolveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            evolveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            evolveButton.heightAnchor.constraint(equalToConstant: 56),
            // Continue button
            continueButton.topAnchor.constraint(equalTo: evolveButton.bottomAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    // MARK: - Error Handling UI
    func handleError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
