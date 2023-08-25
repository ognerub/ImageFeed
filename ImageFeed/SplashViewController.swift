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
    // обращаемся к синглтону shared из ProfileService (локализованный способ)
    private let profileService = ProfileService.shared
    // также обращаемся к shared из ProfileImageService
    private let profileImageService = ProfileImageService.shared
    
    private let profileViewController = ProfileViewController.shared
    
    // обращаемся к расширению ProgressHUD
    private let uiBlockingProgressHUD = UIBlockingProgressHUD.self
    
    private var alertPresenter: AlertPresenterProtocol?
    
//    init (
//        storage: OAuth2TokenStorage = .shared,
//        oAuth2Service: OAuth2Service = .shared,
//        profileService: ProfileService = .shared,
//        profileImageService: ProfileImageService = .shared
//    ) {
//        self.storage = storage
//        self.oAuth2Service = oAuth2Service
//        self.profileService = profileService
//        self.profileImageService = profileImageService
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
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
            guard let token = storage.token else {
                print("Error to guard oAuth2TokenStorage.token while viewDidAppear in SplashVC")
                return }
            //fetchProfileImageSimple(avatarURL: profileImageService.avatarURL ?? "https://unsplash.com")
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
                self.fetchProfileSimple()
            case .failure (let error):
                print("Error to fetchOAuthToken in SplashVC")
                self.showNetWorkErrorForSpashVC(title: "1", error: error)
                self.uiBlockingProgressHUD.dismiss()
            }
        }
    }
    
    func fetchProfileSimple() {
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success:
                print("Success to fetchProfileSimple in SplashVC")
                self.fetchProfileImageSimple()
            case .failure (let error):
                print("Error to fetchProfileSimple in SplashVC")
                self.showNetWorkErrorForSpashVC(title: "2", error: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchProfileImageSimple() {
        profileImageService.fetchProfileImageURL(username: profileService.profile?.username ?? "username") { [weak self] result in
            
            guard let self = self else {return }
            switch result {
            case .success:
                if let url = URL(string: self.profileImageService.avatarURL ?? "") {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                self.profileViewController.personImageView.image = UIImage(data: data)!
                            }
                        }
                    }
                } else {
                    self.profileViewController.personImageView.image = UIImage(systemName: "person.crop.circle.fill")!
                }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
                print("All ok, all data fetched")
            case .failure (let error):
                print("Error to fetchProfileImageSimple in SplashVC")
                self.showNetWorkErrorForSpashVC(title: "3", error: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

// MARK: ShowNetWorkError
extension SplashViewController {
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
}

