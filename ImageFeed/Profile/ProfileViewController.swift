//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Admin on 15.07.2023.
//

import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol! { get set }
    var alertPresenter: AlertPresenterProtocol? { get set }
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var alertPresenter: AlertPresenterProtocol?
    var presenter: ProfilePresenterProtocol!
    
    private let splashViewController = SplashViewController.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func loadView() {
        super.loadView()
        presenter = ProfilePresenter()
        configure(presenter)
        view = presenter.profileView
        presenter.setupSubViews()
        setupExitButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenterImpl(viewController: self)
        
        presenter.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.updateAvatarObjc(notification: notification)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    @objc
    private func updateAvatarObjc(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        presenter.updateAvatar(url: url)
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter.viewController = self
    }
}

// MARK: - Methods to show alert when exit button pressed
extension ProfileViewController {
    func setupExitButton() {
        presenter.exitButton.addTarget(self, action: #selector(didTapExitButton), for: .primaryActionTriggered)
    }
    @objc
    func didTapExitButton() {
        presenter.showAlertBeforExit()
    }
}

// MARK: - Items for tests
/// создаем объект-дублер для первого самостоятельного теста (1 self-test)
final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var alertPresenter: AlertPresenterProtocol?
    var presenter: ProfilePresenterProtocol!
    var configureCalled: Bool = false
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        configureCalled = true
    }
}
