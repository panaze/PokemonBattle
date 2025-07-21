//
//  StarterSelectionUISetup.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 20/07/25.
//

import UIKit

// MARK: - StarterSelectionViewController UI Setup Extension

extension StarterSelectionViewController {
    // MARK: - Card Creation Methods
    func createCardView() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.08
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }
    func createImageView(for starter: StarterOption) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let image = starter.image {
            imageView.image = image
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
            imageView.image = UIImage(systemName: "photo", withConfiguration: config)
            imageView.tintColor = .systemGray3
        }
        return imageView
    }
    func createNameLabel(for starter: StarterOption) -> UILabel {
        let nameLabel = UILabel()
        nameLabel.text = starter.displayName
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }
    func createTypeLabel(for starter: StarterOption) -> UILabel {
        let typeLabel = UILabel()
        typeLabel.text = starter.pokemon.primaryType.capitalized + " Type"
        typeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        typeLabel.textColor = .secondaryLabel
        typeLabel.textAlignment = .left
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        return typeLabel
    }
    func createSelectButton(for starter: StarterOption) -> UIButton {
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Choose \(starter.displayName)", for: .normal)
        selectButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        selectButton.backgroundColor = starter.typeColor
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.layer.cornerRadius = 16
        selectButton.layer.shadowColor = starter.typeColor.cgColor
        selectButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        selectButton.layer.shadowRadius = 8
        selectButton.layer.shadowOpacity = 0.3
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.tag = starter.pokemon.id
        selectButton.addAction(UIAction { [weak self] _ in
            self?.starterButtonTapped(selectButton)
        }, for: .touchUpInside)
        return selectButton
    }
    func setupCardConstraints(
        cardView: UIView,
        imageView: UIImageView,
        nameLabel: UILabel,
        typeLabel: UILabel,
        selectButton: UIButton) {
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 200),
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            typeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            selectButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            selectButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            selectButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            selectButton.heightAnchor.constraint(equalToConstant: 56),
            selectButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }
    // MARK: - Error Handling UI Methods
    func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func showRetryDialog(for error: Error, retryAction: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Connection Error",
            message: error.localizedDescription + "\n\nWould you like to try again?",
            preferredStyle: .alert
        )
        let retryAlertAction = UIAlertAction(title: "Retry", style: .default) { _ in
            retryAction()
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(retryAlertAction)
        alert.addAction(cancelAlertAction)
        present(alert, animated: true)
    }
    // MARK: - UI Update Methods
    func updateUI() {
        showLoading(false)
        if let errorMessage = errorMessage {
            showError(errorMessage)
        } else {
            hideError()
            recreateStarterCards()
        }
    }
    func recreateStarterCards() {
        // Clear existing cards
        starterStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Create new cards with updated data
        for starter in starterOptions {
            let starterCard = createStarterCard(for: starter)
            starterStackView.addArrangedSubview(starterCard)
        }
    }
    func updateStarterCards() {
        // Update existing cards with loaded images
        for (index, starter) in starterOptions.enumerated() where index < starterStackView.arrangedSubviews.count {
            let cardView = starterStackView.arrangedSubviews[index]
            if let imageView = cardView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                if let image = starter.image {
                    imageView.image = image
                    imageView.tintColor = nil
                } else {
                    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
                    imageView.image = UIImage(systemName: "photo", withConfiguration: config)
                    imageView.tintColor = .systemGray3
                }
            }
        }
    }
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        retryButton.isHidden = false
    }
    func hideError() {
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }
    func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            starterStackView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            starterStackView.isHidden = false
        }
    }
    // MARK: - Constraint Setup
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            // Starter stack view
            starterStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            starterStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            starterStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            starterStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32),
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: starterStackView.centerYAnchor),
            // Error label
            errorLabel.topAnchor.constraint(equalTo: starterStackView.bottomAnchor, constant: 24),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            // Retry button
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 200),
            retryButton.heightAnchor.constraint(equalToConstant: 56),
            retryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
}
