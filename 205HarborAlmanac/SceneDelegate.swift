//
//  SceneDelegate.swift
//  205HarborAlmanac
//
//  Created by Roman on 6/4/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var launchFlowResolver: LaunchFlowResolver?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        launchFlowResolver = LaunchFlowResolver(window: window)
        window?.rootViewController = launchFlowResolver?.resolveEntryViewController()
        window?.makeKeyAndVisible()

        launchFlowResolver?.handleOpenURLs(connectionOptions.urlContexts.map(\.url))
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        launchFlowResolver?.handleOpenURLs(URLContexts.map(\.url))
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        launchFlowResolver?.cancelPendingOperations()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
