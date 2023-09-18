//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Admin on 13.09.2023.
//

import UIKit
import Kingfisher

protocol ProfilePresenterProtocol {
    var viewController: ProfileViewControllerProtocol? { get set }
    var profileView: UIView { get set }
    var exitButton: UIButton { get set }
    func setupSubViews()
    func viewDidLoad()
    func viewWillAppear()
    func updateAvatar(url: URL)
    func switchToSplashViewController()
    func showAlertBeforExit()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage.shared
    private let webViewViewController = WebViewViewController.shared
    
    var profileView: UIView = {
        let profileView = UIView(frame: .zero)
        profileView.backgroundColor = UIColor(named: "YP Black")
        return profileView
    }()
    var personImageView: UIImageView = {
        let personImage = UIImage(named: "Avatar") ?? UIImage(systemName: "person.crop.circle.fill")!
        let personImageView = UIImageView(image: personImage)
        personImageView.translatesAutoresizingMaskIntoConstraints = false
        return personImageView
    }()
    var personHashTagLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_now"
        label.textColor = UIColor(named: "YP Grey")
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var personNameLabel: UILabel = {
        let personNameLabel = UILabel()
        personNameLabel.text = "Екатерина Новикова"
        personNameLabel.textColor = UIColor(named: "YP White")
        personNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        personNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return personNameLabel
    }()
    var personInfoTextLabel: UILabel = {
        let personInfoTextLabel = UILabel()
        personInfoTextLabel.text = "Hello, world!"
        personInfoTextLabel.textColor = UIColor(named: "YP White")
        personInfoTextLabel.font = UIFont.systemFont(ofSize: 13)
        personInfoTextLabel.translatesAutoresizingMaskIntoConstraints = false
        return personInfoTextLabel
    }()
    lazy var exitButton: UIButton = {
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: nil
        )
        exitButton.tintColor = UIColor(named: "YP Red")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }()
    
    weak var viewController: ProfileViewControllerProtocol?
    
    private func updateProfileDetails(profile: Profile) {
        personNameLabel.text = profile.name
        personHashTagLabel.text = profile.loginName
        personInfoTextLabel.text = profile.bio
    }
    
    func setupSubViews() {
        addSubViews()
        configureConstraints()
    }
    
    func viewDidLoad() {
        personNameLabel.accessibilityIdentifier = "personNameLabel"
        personHashTagLabel.accessibilityIdentifier = "personHashTagLabel"
        exitButton.accessibilityIdentifier = "exitButton"
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        if let url = profileImageService.avatarURL {
            updateAvatar(url: url)
        }
    }
    
    func viewWillAppear() {
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        guard let avatarURL = profileImageService.avatarURL else { return }
        profileImageService.fetchProfileImageURL(username: profile.username) { _ in
            self.updateAvatar(url: avatarURL)
        }
    }
    
    func updateAvatar(url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        personImageView.kf.indicatorType = .activity
        personImageView.kf.setImage(with: url, options: [.processor(processor)])
        personImageView.layer.masksToBounds = true
        personImageView.layer.cornerRadius = 34
    }
    
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration of switchToSplashViewController") }
        window.rootViewController = SplashViewController()
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
            self.viewController?.alertPresenter?.show(with: model)
        }
    }
}

// MARK: - Setup views
private extension ProfilePresenter {
    func addSubViews() {
        profileView.addSubview(personImageView)
        profileView.addSubview(personNameLabel)
        profileView.addSubview(personHashTagLabel)
        profileView.addSubview(personInfoTextLabel)
        profileView.addSubview(exitButton)
    }
    func configureConstraints() {
        NSLayoutConstraint.activate([
            personImageView.widthAnchor.constraint(equalToConstant: 70),
            personImageView.heightAnchor.constraint(equalToConstant: 70),
            personImageView.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 76),
            personImageView.leadingAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            personNameLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8),
            personNameLabel.leadingAnchor.constraint(equalTo: personImageView.leadingAnchor),
            
            
            personHashTagLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8),            personHashTagLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor),
            
            personInfoTextLabel.topAnchor.constraint(equalTo: personHashTagLabel.bottomAnchor, constant: 8),
            personInfoTextLabel.leadingAnchor.constraint(equalTo: personHashTagLabel.leadingAnchor),
            
            exitButton.centerYAnchor.constraint(equalTo: personImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - Items for tests
/// создаем объект-дублер для первого теста (1-test)
final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var viewController: ProfileViewControllerProtocol?
    var profileView: UIView = UIView()
    var exitButton: UIButton = UIButton()
    var showAlert: Bool = false
    
    func viewDidLoad() { }
    func showAlertBeforExit() { showAlert = true }
    func setupSubViews() { }
    func viewWillAppear() { }
    func updateAvatar(url: URL) { }
    func switchToSplashViewController() { }
}
