//
//  NetworkService.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    // MARK: - Properties
    private let session: URLSession
    private let baseURL = "https://pokeapi.co/api/v2"
    private let failureSimulationEnabled = false
    private let maxRetryAttempts: Int
    // MARK: - Initialization
    private init(session: URLSession = .shared, maxRetryAttempts: Int = 3) {
        self.session = session
        self.maxRetryAttempts = maxRetryAttempts
        if failureSimulationEnabled {
            print("NetworkService initialized with 50% failure simulation ENABLED")
        }
    }
    // MARK: - Public Methods
    /// Fetches Pokemon data from PokeAPI with retry logic
    /// - Parameter id: Pokemon ID to fetch
    /// - Returns: PokemonAPIResponse containing Pokemon data
    /// - Throws: Network error if all retry attempts fails
    func fetchPokemonData(id: Int) async throws -> PokemonAPIResponse {
        guard let url = URL(string: "\(baseURL)/pokemon/\(id)") else {
            throw NetworkError.invalidURL
        }
        return try await withRetry(maxAttempts: maxRetryAttempts) {
            // Simulate network failure if needed
            if self.simulateNetworkFailure() {
                throw NetworkError.simulatedFailure
            }
            let (data, response) = try await self.session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            do {
                return try JSONDecoder().decode(PokemonAPIResponse.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        }
    }
    /// Download image data from URL with retry attempts
    /// - Parameter url: Image URL String
    /// - Returns: Image data
    /// - Throws: NetworkError if download fails
    func downloadImage(from url: String) async throws -> Data {
        guard let imageUrl = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        return try  await withRetry(maxAttempts: maxRetryAttempts) {
            // Simulate network failure if enabled
            if self.simulateNetworkFailure() {
                throw NetworkError.simulatedFailure
            }
            let (data, response) = try await self.session.data(from: imageUrl)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            return data
        }
    }
    /// Simulates network failure
    /// - Returns: Boolean indicating if failure should be simulated
    func simulateNetworkFailure() -> Bool {
        guard failureSimulationEnabled else { return false }
        // 50% chance of failure when simulation is enabled
        return Double.random(in: 0...1) < 0.5
    }
    // MARK: - Private Methods
    /// Executes an operation with exponential backoff retry logic
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts
    ///   - operation:  Async operation to retry
    /// - Returns: Result of the operation
    /// - Throws: Last error encountered if all attempts fail
    private func withRetry<T>(maxAttempts: Int, operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                if failureSimulationEnabled && error is NetworkError {
                    print("Retry attempt \(attempt)/\(maxAttempts) - Error: \(error.localizedDescription)")
                }
                // Not wait after until last attempt
                if attempt < maxAttempts {
                    let delay = calculateBackoffDelay(for: attempt)
                    try await Task.sleep(for: .seconds(delay))
                }
            }
        }
        // If we exhausted all attempts, throw maxRetriesExceeded or the last error
        if let lastError = lastError {
            if case NetworkError.simulatedFailure = lastError {
                throw NetworkError.maxRetriesExceeded
            }
            throw lastError
        } else {
            throw NetworkError.maxRetriesExceeded
        }
    }
    /// Calculates exponential backoff delay
    /// - Parameter attempt: Current attempt number
    /// - Returns: Delay in seconds
    private func calculateBackoffDelay(for attempt: Int) -> Double {
        return pow(2.0, Double(attempt - 1))
    }
}
