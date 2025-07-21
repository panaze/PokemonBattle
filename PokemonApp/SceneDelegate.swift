//
//  SceneDelegate.swift
//  PokemonApp
//
//  Created by Pablo Navarro Zepeda on 17/07/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var mainCoordinator: MainCoordinator?
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // Create window
        window = UIWindow(windowScene: windowScene)
        // Create navigation controller
        let navigationController = UINavigationController()
        // Create and start main coordinator directly
        mainCoordinator = MainCoordinator(navigationController: navigationController)
        // Set up window
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        // Start the coordinator
        mainCoordinator?.start()
    }
}
