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
    
    private var alertPresenter: AlertPresenterProtocol?
    
    var showError: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        alertPresenter = AlertPresenterImpl(viewController: self)
        
        if oAuth2TokenStorage.token != nil  {
            guard let token = oAuth2TokenStorage.token else {
                print("Error to guard oAuth2TokenStorage.token while viewDidAppear in SplashVC")
                return }
            showError = false
            fetchProfileSimple(token: token)
            //fetchProfileImageSimple(avatarURL: profileImageService.avatarURL ?? "https://unsplash.com")
            switchToTabBarController()
        } else {
            if showError == true {
                showNetWorkErrorForSpashVC()
            } else {
                performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
    
    private func showNetWorkErrorForSpashVC() {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: "Что-то пошло не так(",
                message: "Не удалось войти в систему",
                buttonText: "OK",
                completion: { [weak self] in guard let self = self else { return }
                    self.performSegue(withIdentifier: self.showAuthenticationScreenSegueIdentifier, sender: nil)
                })
            self.alertPresenter?.show(with: model)
        }
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
                self.showError = false
                self.switchToTabBarController()
                self.uiBlockingProgressHUD.dismiss()
            case .failure:
                print("Error to fetchOAuthToken in SplashVC")
                self.showError = true
                self.uiBlockingProgressHUD.dismiss()
                // TODO 11 sprint
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
                self.showError = false
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                print("Error to fetchProfileSimple in SplashVC")
                self.showError = true
                UIBlockingProgressHUD.dismiss()
                // TODO 11 sprint
                
                self.showNetWorkErrorForSpashVC()
                
                break
            }
        }
    }
    
    private func fetchProfileImageSimple(avatarURL: String) {
        profileImageService.fetchProfileImageURL(username: profileService.profile?.username ?? "username") { [weak self] result in
            
            guard let self = self else {return }
            switch result {
            case .success:
                //                if let url = URL(string: avatarURL) {
                //                    DispatchQueue.global().async {
                //                        if let data = try? Data(contentsOf: url) {
                //                            DispatchQueue.main.async {
                //                                //ProfileViewController().personImageView.image = UIImage(data: data)!
                //                            }
                //                        }
                //                    }
                //                } else {
                //                    //ProfileViewController().personImageView.image = UIImage(systemName: "person.crop.circle.fill")!
                //                }
                print("All ok, avatar URL")
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
}

