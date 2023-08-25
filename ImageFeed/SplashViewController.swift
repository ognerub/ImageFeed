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
    
    private var allDataFetched: Bool = false
    
    var topVC: UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenterImpl(viewController: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        if oAuth2TokenStorage.token != nil && allDataFetched {
            guard let token = oAuth2TokenStorage.token else {
                print("Error to guard oAuth2TokenStorage.token while viewDidAppear in SplashVC")
                return }
            //fetchProfileImageSimple(avatarURL: profileImageService.avatarURL ?? "https://unsplash.com")
            switchToTabBarController()
        } else {
            //showNetWorkErrorForSpashVC()
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            
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
            guard let viewController = segue.destination as? AuthViewController else { return }
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
    
    private func showNetWorkErrorForSpashVC(title: String, error: Error) {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: title, //"Что-то пошло не так(",
                message: "Не удалось войти в систему \(error)",
                buttonText: "OK",
                completion: { [weak self] in guard let self = self else { return }
                    self.performSegue(withIdentifier: self.showAuthenticationScreenSegueIdentifier, sender: nil)
                })
            self.alertPresenter?.show(with: model)
        }
    }
    
//    func show(with alertModel: AlertModel) {
//        let alert = UIAlertController(
//            title: alertModel.title,
//            message: alertModel.message,
//            preferredStyle: .alert)
//        let action = UIAlertAction(
//            title: alertModel.buttonText,
//            style: .default) { _ in
//            alertModel.completion()
//        }
//        alert.addAction(action)
//        presentedViewController?.present(alert,
//                                animated: true)
//    }
    
}

// MARK: - SplashViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        uiBlockingProgressHUD.show()
        dismiss(animated: true) {
            [weak self] in guard let self = self
            else { return }
            
            self.fetchOAuthToken(code)
            //self.fetchProfileSimple()
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
                self.fetchProfileSimple()
                //self.switchToTabBarController()
                //self.uiBlockingProgressHUD.dismiss()
            case .failure (let error):
                print("Error to fetchOAuthToken in SplashVC")
                self.showNetWorkErrorForSpashVC(title: "1", error: error)
                self.uiBlockingProgressHUD.dismiss()
                // TODO 11 sprint
                //break
            }
        }
    }
    
    func fetchProfileSimple() {
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success:
                print("Success to fetchProfileSimple in SplashVC")
                UIBlockingProgressHUD.dismiss()
                self.allDataFetched = true
                self.switchToTabBarController()
            case .failure (let error):
                print("Error to fetchProfileSimple in SplashVC")
                self.showNetWorkErrorForSpashVC(title: "2", error: error)
                UIBlockingProgressHUD.dismiss()
                // TODO 11 sprint
                
                //break
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

