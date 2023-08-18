//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Admin on 15.07.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let personImageView: UIImageView = {
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
    // обращаемся к синглтону shared из ProfileService (локализованный способ)
    private let profileService = ProfileService.shared
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        configureConstraints()
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        fetchProfileImageSimple(token: oAuth2TokenStorage.token ?? "")
    }

    private func fetchProfileImageSimple(token: String) {
        ProfileImageService().fetchProfileImageURL(username: profileService.profile?.username ?? "username") { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success:
                print("Success to fetchProfileImageSimple in ProfileVC")
            case .failure:
                print("Error to fetchProfileImageSimple in ProfileVC")
                // TODO [Sprint 11]
                break
            }
        }
        
    }
    
    private func updateProfileDetails(profile: Profile) {
        personNameLabel.text = profile.name
        personHashTagLabel.text = profile.loginName
        personInfoTextLabel.text = profile.bio
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
    
    @objc
    private func didTapButton() {
        
    }
    
}
