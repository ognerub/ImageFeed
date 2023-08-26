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
    
    private let storage = OAuth2TokenStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileViewController = ProfileViewController.shared

    private let uiBlockingProgressHUD = UIBlockingProgressHUD.self
    
    private let auth = AuthViewController.shared
  
//    /// используем эту переменную для определения VC находящегося на самом верхнем слое отображения
//    var topVC: UIViewController {
//        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
//        while (topController.presentedViewController != nil) {
//            topController = topController.presentedViewController!
//        }
//        return topController
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenterImpl(viewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if storage.token != nil {
            fetchProfileSimple()
            profileImageService.fetchProfileImageURL(username: profileService.profile?.username ?? "username") { _ in }
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let viewController = segue.destination as? AuthViewController else { return }
            viewController.delegate = self
        } else {
            showAuthViewController()
            //performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func showAuthViewController() {
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewController")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == showAuthenticationScreenSegueIdentifier {
//                guard
//                    let navigationController = segue.destination as? UINavigationController,
//                    let viewController = navigationController.viewControllers[0] as? AuthViewController
//                else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")}
//                viewController.delegate = self
//            } else {
//                super.prepare(for: segue, sender: sender)
//            }
//        }
//
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
                //self.fetchProfileSimple(token: self.oAuth2TokenStorage.token ?? "")
                //self.fetchProfileImageSimple(avatarURL: )
                
            
        }
    }
}

// MARK: - Fetch functions
extension SplashViewController {
    func fetchOAuthToken(_ code: String) {
        
        //self.uiBlockingProgressHUD.show()
        
        oAuth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProfileSimple()
            case .failure:
                self.showNetWorkErrorForSpashVC()
                self.uiBlockingProgressHUD.dismiss()
            }
        }
    }
    
    func fetchProfileSimple() {
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else {return }
            
            switch result {
            case .success:
                self.profileImageService.fetchProfileImageURL(username: self.profileService.profile?.username ?? "username") { _ in }
                self.switchToTabBarController()
            case .failure:
                self.showNetWorkErrorForSpashVC()
                UIBlockingProgressHUD.dismiss()
            }
            completion()
        }
    }
}

// MARK: ShowNetWorkError
extension SplashViewController {
    private func showNetWorkErrorForSpashVC() {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: "Что-то пошло не так(",
                message: "Не удалось войти в систему",
                buttonText: "OK",
                completion: { [weak self] in guard let self = self else { return }
                    self.storage.nilTokenInUserDefaults()
                })
            self.alertPresenter?.show(with: model)
        }
    }
}

