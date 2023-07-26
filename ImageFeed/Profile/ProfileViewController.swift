//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Admin on 15.07.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showProfileItems()
    }
    
    private func showProfileItems() {
        let personImage = UIImage(named: "Avatar") ?? UIImage(systemName: "person.crop.circle.fill")!
        let personImageView = UIImageView(image: personImage)
        func showPersonImage() {
            view.addSubview(personImageView)
            personImageView.translatesAutoresizingMaskIntoConstraints = false
            personImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
            personImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
            personImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76).isActive = true
            personImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        }
        showPersonImage()
        
        let personNameLabel = UILabel()
        func showPersonName() {
            personNameLabel.text = "Екатерина Новикова"
            view.addSubview(personNameLabel)
            personNameLabel.textColor = UIColor(named: "YP White")
            personNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
            personNameLabel.translatesAutoresizingMaskIntoConstraints = false
            personNameLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8).isActive = true
            personNameLabel.leadingAnchor.constraint(equalTo: personImageView.leadingAnchor).isActive = true
        }
        showPersonName()
        
        let personHashTagLabel = UILabel()
        func showPersonHashTag() {
            personHashTagLabel.text = "@ekaterina_nov"
            view.addSubview(personHashTagLabel)
            personHashTagLabel.textColor = UIColor(named: "YP Grey")
            personHashTagLabel.font = UIFont.systemFont(ofSize: 13)
            personHashTagLabel.translatesAutoresizingMaskIntoConstraints = false
            personHashTagLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8).isActive = true
            personHashTagLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor).isActive = true
        }
        showPersonHashTag()
        
        let personInfoTextLabel = UILabel()
        func showPersonInfoTextLabel() {
            personInfoTextLabel.text = "Hello, world!"
            view.addSubview(personInfoTextLabel)
            personInfoTextLabel.textColor = UIColor(named: "YP White")
            personInfoTextLabel.font = UIFont.systemFont(ofSize: 13)
            personInfoTextLabel.translatesAutoresizingMaskIntoConstraints = false
            personInfoTextLabel.topAnchor.constraint(equalTo: personHashTagLabel.bottomAnchor, constant: 8).isActive = true
            personInfoTextLabel.leadingAnchor.constraint(equalTo: personHashTagLabel.leadingAnchor).isActive = true
        }
        showPersonInfoTextLabel()
        
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        func showExitButton() {
            view.addSubview(exitButton)
            exitButton.tintColor = UIColor(named: "YP Red")
            exitButton.translatesAutoresizingMaskIntoConstraints = false
            exitButton.centerYAnchor.constraint(equalTo: personImageView.centerYAnchor).isActive = true
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        }
        showExitButton()
    }
    
    @objc
    private func didTapButton() {
        
    }
    
}
