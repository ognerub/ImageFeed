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
    
    private let auth: AuthViewController = AuthViewController()
    
    var alertPresenter: AlertPresenterProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SplashVC viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("SplashVC viewDidAppear")
        
        alertPresenter = AlertPresenterImpl(viewController: self)
        
        
        if oAuth2TokenStorage.token != nil {
            guard let token = oAuth2TokenStorage.token else {
                print("Error to guard oAuth2TokenStorage.token while viewDidAppear in SplashVC")
                return }
            fetchProfileSimple(token: token)
            //fetchProfileImageSimple(avatarURL: profileImageService.avatarURL ?? "https://unsplash.com")
            switchToTabBarController()
        } else {
                if self.oAuth2Service.errorVar != nil {
                        self.showNetWorkErrorForSpashVC()
                    
                    
                } else {
                    self.performSegue(withIdentifier: self.showAuthenticationScreenSegueIdentifier, sender: nil)
                
            }
            
        }
        
        print("SplashVC ends")
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
    
    
    func showNetWorkErrorForSpashVC() {
        DispatchQueue.main.async {
            //            let model = AlertModel(
            //                title: "Что-то пошло не так(",
            //                message: "Не удалось войти в систему",
            //                buttonText: "OK",
            //                completion: { [weak self] in guard let self = self else { return }
            //                    // nothing to do
            //
            //                })
            //            self.alertPresenter?.show(with: model)
            //}
            let alert = UIAlertController(title: "Alert!", message: "No message", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            //vc.view.layoutIfNeeded()
                self.present(alert, animated: true, completion: {
                    self.oAuth2Service.errorVar = nil
                    self.performSegue(withIdentifier: self.showAuthenticationScreenSegueIdentifier, sender: nil)
                })
            
//            self.addChild(vc)
//            vc.didMove(toParent: self)
//            self.view.addSubview(vc.view)
            
        }
    }
    
    
    
}

// MARK: - SplashViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        
            self.uiBlockingProgressHUD.show()
            
            self.dismiss(animated: true) {
                [weak self] in guard let self = self
                else { return }
                self.fetchOAuthToken(code)
                self.fetchProfileSimple(token: self.oAuth2TokenStorage.token ?? "")
                //self.fetchProfileImageSimple(avatarURL: )
                
            
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
                case .failure (let error):
                    print("Error to fetchOAuthToken in SplashVC \(error)")
                    self.uiBlockingProgressHUD.dismiss()
                    // TODO 11 sprint
                    
                    self.oAuth2Service.errorVar = error
                    
                    
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
                break
            }
        }
    }
}

