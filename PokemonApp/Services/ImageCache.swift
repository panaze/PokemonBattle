//
//  ImageCache.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 19/07/25.
//

import Foundation
import UIKit

/// Image caching service using NSCache for sprite caching
class ImageCache {
    static let shared = ImageCache()
    // MARK: - Properties
    private let cache = NSCache<NSString, UIImage>()
    private let networkService: NetworkService
    private let cacheQueue = DispatchQueue(label: "com.pokemonapp.imagecache", qos: .utility)
    // MARK: - Initialization
    private init() {
        self.networkService = NetworkService.shared
        setupCache()
    }
    // MARK: - Public Methods
    /// Retrieves cached image for the given URL
    /// - Parameter url: Image URL string
    /// - Returns: Catched UIImage if available, nil otherwise
    func cachedImage(for url: String) -> UIImage? {
        return cache.object(forKey: NSString(string: url))
    }
    /// Caches an image to the given URL
    /// - Parameters:
    ///   - image: UIImage to cache
    ///   - url: URL string to use as cache key
    func cacheImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: NSString(string: url))
    }
    /// Download and caches an image from the given URL
    /// - Parameter url: Image URL string
    /// - Returns: Downloaded UIImage
    /// - Throws: ImageError if downloa or conversion from imagedata to UIImage
    func downloadAndCacheImage(from url: String) async throws -> UIImage {
        // Check cache first
        if let cachedImage = cachedImage(for: url) {
            return cachedImage
        }
        // Download image data
        let imageData = try await networkService.downloadImage(from: url)
        // Convert to UIImage
        guard let image = UIImage(data: imageData) else {
            throw ImageError.invalidData
        }
        // Cache the image
        cacheImage(image, for: url)
        return image

    }
    // MARK: - Public Methods
    /// Clears all cached image
    func clearCache() {
        cache.removeAllObjects()
    }
    /// Gets the current cache count
    var cacheCount: Int {
        return cache.totalCostLimit
    }
    // MARK: - Private Methods
    /// Setup cache configuration
    private func setupCache() {
        // Set cache limits
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
        // Set cache name for debugging
        cache.name = "PokemonSpriteCache"
    }
}
