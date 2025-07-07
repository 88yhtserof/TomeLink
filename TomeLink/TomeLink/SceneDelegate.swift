//
//  SceneDelegate.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/29/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        NetworkMonitorManager.shared.startMonitoring()
        let rootViewController = TabBarController()
//        let rootViewController = NotiListViewController()
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }
}

