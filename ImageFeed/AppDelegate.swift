//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Admin on 01.07.2023.
//

import UIKit
import ProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ProgressHUD.animationType = .systemActivityIndicator
        ProgressHUD.colorAnimation = UIColor(named: "YP Black") ?? .black
        ProgressHUD.colorHUD = UIColor(named: "YP White") ?? .white
        ProgressHUD.mediaSize = 25
        ProgressHUD.marginSize = 25
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(          // 1
            name: "Main",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self   // 2
        return sceneConfiguration
    }
}

