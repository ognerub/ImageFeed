//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Admin on 15.07.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    static let shared = ProfileViewController()
    
    var personImageView: UIImageView = {
        let personImage = UIImage(named: "Avatar") ?? UIImage(systemName: "person.crop.circle.fill")!
        let personImageView = UIImageView(image: personImage)
        personImageView.translatesAutoresizingMaskIntoConstraints = false
        return personImageView
    }()
    private let personHashTagLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_now"
        label.textColor = UIColor(named: "YP Grey")
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let personNameLabel: UILabel = {
        let personNameLabel = UILabel()
        personNameLabel.text = "Екатерина Новикова"
        personNameLabel.textColor = UIColor(named: "YP White")
        personNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        personNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return personNameLabel
    }()
    private let personInfoTextLabel: UILabel = {
        let personInfoTextLabel = UILabel()
        personInfoTextLabel.text = "Hello, world!"
        personInfoTextLabel.textColor = UIColor(named: "YP White")
        personInfoTextLabel.font = UIFont.systemFont(ofSize: 13)
        personInfoTextLabel.translatesAutoresizingMaskIntoConstraints = false
        return personInfoTextLabel
    }()
    private lazy var exitButton: UIButton = {
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        exitButton.tintColor = UIColor(named: "YP Red")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private let splashViewControllerIdentifier = "SplashViewController"
    private let mainUIStoryboard = "Main"
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        configureConstraints()
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
        guard let profile = profileService.profile else {
            print("no saved profile")
            return
        }
        updateProfileDetails(profile: profile)
        guard let avatarURL = profileImageService.avatarURL else {
            print("no saved avatarURL")
            return
        }
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
        personImageView.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        personImageView.kf.setImage(with: url, options: [.processor(processor)])
        //personImageView.image = profileImageService.avatarImage
        personImageView.layer.masksToBounds = true
        personImageView.layer.cornerRadius = 34
    }
    
    private func updateProfileDetails(profile: Profile) {
        // change profile text
        personNameLabel.text = profile.name
        personHashTagLabel.text = profile.loginName
        personInfoTextLabel.text = profile.bio
        
        // change profile image
        
    }
    
    private func addSubViews() {
        view.addSubview(personImageView)
        view.addSubview(personNameLabel)
        view.addSubview(personHashTagLabel)
        view.addSubview(personInfoTextLabel)
        view.addSubview(exitButton)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            personImageView.widthAnchor.constraint(equalToConstant: 70),
            personImageView.heightAnchor.constraint(equalToConstant: 70),
            personImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            personImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            personNameLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8),
            personNameLabel.leadingAnchor.constraint(equalTo: personImageView.leadingAnchor),
            
            personHashTagLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8),            personHashTagLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor),
            
            personInfoTextLabel.topAnchor.constraint(equalTo: personHashTagLabel.bottomAnchor, constant: 8),
            personInfoTextLabel.leadingAnchor.constraint(equalTo: personHashTagLabel.leadingAnchor),
            
            exitButton.centerYAnchor.constraint(equalTo: personImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration of switchToSplashViewController") }
        let splashViewController = UIStoryboard(name: mainUIStoryboard, bundle: .main)
            .instantiateViewController(withIdentifier: splashViewControllerIdentifier)
        window.rootViewController = splashViewController
    }
    
    @objc
    private func didTapButton() {
        storage.nilTokenInUserDefaults()
        switchToSplashViewController()
    }
}
