//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Admin on 07.08.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    static let shared = SplashViewController()
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tabBarViewControllerIdentifier = "TabBarController"
    private let authViewControllerIdentifier = "AuthViewController"
    private let mainUIStoryboard = "Main"
    private let storage = OAuth2TokenStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private var unsplashLogo: UIImageView = {
        let unsplashLogoImage = UIImage(named: "Vector") ?? UIImage(systemName: "sun")!
        let unsplashLogoView = UIImageView(image: unsplashLogoImage)
        unsplashLogoView.translatesAutoresizingMaskIntoConstraints = false
        return unsplashLogoView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenterImpl(viewController: self)
        addSubViews()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if storage.token != nil {
            fetchProfileSimple()
            fetchProfileImageSimple()
            switchToTabBarController()
        } else {
            showAuthViewController()
        }
    }
    
    func showAuthViewController() {
        let viewController = UIStoryboard(name: mainUIStoryboard, bundle: .main).instantiateViewController(identifier: authViewControllerIdentifier)
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration of switchToTabBarController") }
        let tabBarController = UIStoryboard(name: mainUIStoryboard, bundle: .main)
            .instantiateViewController(withIdentifier: tabBarViewControllerIdentifier)
        window.rootViewController = tabBarController
    }
    
    private func addSubViews() {
        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(unsplashLogo)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            unsplashLogo.widthAnchor.constraint(equalToConstant: 75),
            unsplashLogo.heightAnchor.constraint(equalToConstant: 77.67),
            unsplashLogo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -37.5),
            unsplashLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -38.835),
        ])
    }
}

// MARK: - SplashViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
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
                self.fetchProfileSimple()
            case .failure:
                self.showNetWorkErrorForSpashVC()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    func fetchProfileSimple() {
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success:
                self.fetchProfileImageSimple()
            case .failure:
                self.showNetWorkErrorForSpashVC()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchProfileImageSimple() {
        profileImageService.fetchProfileImageURL(username: profileService.profile?.username ?? "username") { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                self.showNetWorkErrorForSpashVC()
                UIBlockingProgressHUD.dismiss()
            }
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
                completion: { })
            self.alertPresenter?.show(with: model)
        }
    }
}

