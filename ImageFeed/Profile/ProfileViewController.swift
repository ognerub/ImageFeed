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
    
    func showProfileItems() {
        let personImage = UIImage(named: "Avatar")
        let personImageView = UIImageView(image: personImage)
        view.addSubview(personImageView)
        personImageView.translatesAutoresizingMaskIntoConstraints = false
        personImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        personImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        personImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76).isActive = true
        personImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        let personNameLabel = UILabel()
        personNameLabel.text = "Екатерина Новикова"
        view.addSubview(personNameLabel)
        personNameLabel.textColor = UIColor(named: "YP White")
        personNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        personNameLabel.translatesAutoresizingMaskIntoConstraints = false
        personNameLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8).isActive = true
        personNameLabel.leadingAnchor.constraint(equalTo: personImageView.leadingAnchor).isActive = true
        
        let personHashTagLabel = UILabel()
        personHashTagLabel.text = "@ekaterina_nov"
        view.addSubview(personHashTagLabel)
        personHashTagLabel.textColor = UIColor(named: "YP Grey")
        personHashTagLabel.font = UIFont.systemFont(ofSize: 13)
        personHashTagLabel.translatesAutoresizingMaskIntoConstraints = false
        personHashTagLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8).isActive = true
        personHashTagLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor).isActive = true
        
        let personInfoTextLabel = UILabel()
        personInfoTextLabel.text = "Hello, world!"
        view.addSubview(personInfoTextLabel)
        personInfoTextLabel.textColor = UIColor(named: "YP White")
        personInfoTextLabel.font = UIFont.systemFont(ofSize: 13)
        personInfoTextLabel.translatesAutoresizingMaskIntoConstraints = false
        personInfoTextLabel.topAnchor.constraint(equalTo: personHashTagLabel.bottomAnchor, constant: 8).isActive = true
        personInfoTextLabel.leadingAnchor.constraint(equalTo: personHashTagLabel.leadingAnchor).isActive = true
        
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "LogOut")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        view.addSubview(exitButton)
        exitButton.tintColor = UIColor(named: "YP Red")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.centerYAnchor.constraint(equalTo: personImageView.centerYAnchor).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    @objc
    private func didTapButton() {
        
    }
    
}
