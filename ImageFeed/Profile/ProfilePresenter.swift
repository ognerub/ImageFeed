//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Admin on 13.09.2023.
//

import Foundation
import UIKit

public protocol ProfilePresenterProtocol {
    var viewController: ProfileViewControllerProtocol? { get set }
    
}

final class ProfilePresenter: UIView, ProfilePresenterProtocol {
    
    weak var viewController: ProfileViewControllerProtocol?
    
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
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(named: "YP Black")
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        addSubViews()
        configureConstraints()
    }
}

// MARK: - Setup views
private extension ProfilePresenter {
    func addSubViews() {
        addSubview(personImageView)
        addSubview(personNameLabel)
        addSubview(personHashTagLabel)
        addSubview(personInfoTextLabel)
        addSubview(exitButton)
    }
    func configureConstraints() {
        NSLayoutConstraint.activate([
            personImageView.widthAnchor.constraint(equalToConstant: 70),
            personImageView.heightAnchor.constraint(equalToConstant: 70),
            personImageView.topAnchor.constraint(equalTo: topAnchor, constant: 76),
            personImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            personNameLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8),
            personNameLabel.leadingAnchor.constraint(equalTo: personImageView.leadingAnchor),
            
            
            personHashTagLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8),            personHashTagLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor),
            
            personInfoTextLabel.topAnchor.constraint(equalTo: personHashTagLabel.bottomAnchor, constant: 8),
            personInfoTextLabel.leadingAnchor.constraint(equalTo: personHashTagLabel.leadingAnchor),
            
            exitButton.centerYAnchor.constraint(equalTo: personImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
