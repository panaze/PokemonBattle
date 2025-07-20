//
//  ErrorTypes.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation

// MARK: - Error Types

/// Network  errors that can occur during API requests and data fetching
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case simulatedFailure
    case maxRetriesExceeded
    case noData
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid HTTP response received"
        case .decodingError:
            return "Error decoding JSON data"
        case .simulatedFailure:
            return "Simulated network failure for testing purposes"
        case .maxRetriesExceeded:
            return "Maximum retries exceeded"
        case .noData:
            return "No data returned from the server"
        }
    }
}

/// Image related-errors
enum ImageError: Error {
    case invalidData
    case downloadFailed
    case cacheError
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid image data"
        case .downloadFailed:
            return "Image download failed"
        case .cacheError:
            return "Error caching image"
        }
    }
}

/// Persistance-related errors
enum PersistenceError: Error, LocalizedError {
    case saveError
    case loadError
    var errorDescription: String? {
        switch self {
        case .saveError:
            return "Error saving data"
        case .loadError:
            return "Error loading data"
        }
    }
}

/// Evolution-specific errors
enum EvolutionError: Error, LocalizedError {
    case cannotEvolve
    case noEvolutionData
    case fetchFailed(Error)
    var errorDescription: String? {
        switch self {
        case .cannotEvolve:
            return "Pokemon cannot evolve at this time"
        case .noEvolutionData:
            return "No evolution data available for this Pokemon"
        case .fetchFailed(let error):
            return "Failed to fetch evolution data: \(error.localizedDescription)"
        }
    }
}
