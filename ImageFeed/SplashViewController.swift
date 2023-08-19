//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Admin on 07.08.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tabBarViewControllerIdentifier = "TabBarViewController"
    private let mainUIStoryboard = "Main"
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let oAuth2Service = OAuth2Service()
    // обращаемся к синглтону shared из ProfileService (локализованный способ)
    private let profileService = ProfileService.shared
    // также обращаемся к shared из ProfileImageService
    private let profileImageService = ProfileImageService.shared
    // обращаемся к расширению ProgressHUD
    private let uiBlockingProgressHUD = UIBlockingProgressHUD.self
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oAuth2TokenStorage.token != nil  {
            guard let token = oAuth2TokenStorage.token else {
                print("Error to guard oAuth2TokenStorage.token while viewDidAppear in SplashVC")
                return }
            fetchProfileSimple(token: token)
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")}
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration of switchToTabBarController") }
        let tabBarController = UIStoryboard(name: mainUIStoryboard, bundle: .main)
            .instantiateViewController(withIdentifier: tabBarViewControllerIdentifier)
        window.rootViewController = tabBarController
    }
    
}

// MARK: - SplashViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        uiBlockingProgressHUD.show()
        dismiss(animated: true) {
            [weak self] in guard let self = self
            else { return }
            self.fetchOAuthToken(code)
        }
    }
}

// MARK: - Fetch functions
extension SplashViewController {
    func fetchOAuthToken(_ code: String) {
        oAuth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print("Success to fetchOAuthToken in SplashVC")
                self.switchToTabBarController()
                self.uiBlockingProgressHUD.dismiss()
            case .failure:
                print("Error to fetchOAuthToken in SplashVC")
                self.uiBlockingProgressHUD.dismiss()
                // TODO [Sprint 11]
                break
            }
        }
    }
    
    func fetchProfileSimple(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success:
                print("Success to fetchProfileSimple in SplashVC")
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                print("Error to fetchProfileSimple in SplashVC")
                UIBlockingProgressHUD.dismiss()
                // TODO [Sprint 11]
                break
            }
        }
    }
    
    
}

