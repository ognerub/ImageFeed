//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Admin on 15.07.2023.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol! { get set }
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol!
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter.viewController = self
    }
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage.shared
    private let splashViewController = SplashViewController.shared
    private let webViewViewController = WebViewViewController.shared
    
    private var alertPresenter: AlertPresenterProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func loadView() {
        view = ProfilePresenter()
        setupExitButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenterImpl(viewController: self)
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.updateAvatar(notification: notification)
        }
        if let url = profileImageService.avatarURL {
            updateAvatar(url: url)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        
        guard let avatarURL = profileImageService.avatarURL else { return }
        profileImageService.fetchProfileImageURL(username: profile.username) { _ in
            self.updateAvatar(url: avatarURL)
        }
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        updateAvatar(url: url)
    }
    
    private func updateAvatar(url: URL) {
        (view as? ProfilePresenter)?.personImageView.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        (view as? ProfilePresenter)?.personImageView.kf.setImage(with: url, options: [.processor(processor)])
        (view as? ProfilePresenter)?.personImageView.layer.masksToBounds = true
        (view as? ProfilePresenter)?.personImageView.layer.cornerRadius = 34
    }

    private func updateProfileDetails(profile: Profile) {
        (view as? ProfilePresenter)?.personNameLabel.text = profile.name
        (view as? ProfilePresenter)?.personHashTagLabel.text = profile.loginName
        (view as? ProfilePresenter)?.personInfoTextLabel.text = profile.bio
    }

    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration of switchToSplashViewController") }
        window.rootViewController = SplashViewController()
    }
}

// MARK: - Methods to show alert when exit button pressed
extension ProfileViewController {
    func setupExitButton() {
        (view as? ProfilePresenter)?.exitButton.addTarget(self, action: #selector(didTapExitButton), for: .primaryActionTriggered)
    }
    @objc
    func didTapExitButton() {
        showAlertBeforExit()
    }
    func showAlertBeforExit() {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: "Пока, пока!",
                message: "Уверены что хотите выйти?",
                firstButton: "Да",
                secondButton: "Нет",
                firstCompletion: {
                    self.storage.nilTokenInUserDefaults()
                    self.webViewViewController.cleanWebViewAfterUse()
                    self.switchToSplashViewController()
                },
                secondCompletion: { })
            self.alertPresenter?.show(with: model)
        }
    }
}
