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
    // обращаемся ко второму shared из ProfileImageService
    private let profileImageService = ProfileImageService.shared
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    private let splashViewControllerIdentifier = "SplashViewController"
    private let mainUIStoryboard = "Main"
    
    /// Example with selectors --->
//    // перегружаем конструктор
//    override init(nibName: String?, bundle: Bundle?) {
//        super.init(nibName: nibName, bundle: bundle)
//        addObserver()
//    }
//    // определяем конструктор, необходимый при декодировании класса из Storyboard
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        addObserver()
//    }
//    // определям деструктор
//    deinit {
//        removeObserver()
//    }
    /// ---<
    
    /// Example with blocks --->
    private var profileImageServiceObserver: NSObjectProtocol? // 1 объявляем свойство для хранения обсервера
    /// ---<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        configureConstraints()
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        
        /// Example with selectors continue --->
//        if let avatarURL = ProfileImageService.shared.avatarURL,
//           let url = URL(string: avatarURL) {
//               // TODO обновить аватар, если нотификация была опубликована до того, как мы подписались
//           }
        /// ---<
        
        /// Example with blocks continue --->
        profileImageServiceObserver = NotificationCenter.default // 2 присваиваем в свойство обсервер, возвращаемый функцией .addObserver
            .addObserver(
                forName: ProfileImageService.DidChangeNotification, // 3 имя уведомления
                object: nil, // 4 так как хотим получать уведомления от любых источников
                queue: .main // 5 указываем главную очередь, так как в обработчике нотификаций будем обновлять UI!
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar() // 6 вызываем функцию для обновления аватара
            }
        updateAvatar() // 7 добавленный наблюдатель (обсервер) будет получать уведомления (нотификацию) после добавления, но может случится, что запрос на получение аватарки уже успел завершиться, поэтому во viewDidLoad также пытаеся обновить аватарку
        /// ---<
    }
    
    /// Example with blocks continue --->
    private func updateAvatar() { // 8 метод обновления аватарки
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        // TODO обновление аватара используя Kingfisher
    }
    /// ---<
    
    /// Example with selectors continue --->
//    private func addObserver() {
//        NotificationCenter.default.addObserver(
//        self,
//        selector: #selector(updateAvatar(notification:)),
//        name: ProfileImageService.DidChangeNotification,
//        object: nil)
//    }
//    private func removeObserver() {
//        NotificationCenter.default.removeObserver(
//            self,
//            name: ProfileImageService.DidChangeNotification,
//            object: nil)
//    }
//    @objc
//        private func updateAvatar(notification: Notification) {
//            guard
//                isViewLoaded,
//                let userInfo = notification.userInfo,
//                let profileImageURL = userInfo["URL"] as? String,
//                let url = URL(string: profileImageURL)
//            else {return}
//
//            // TODO обновить аватар используя Kingfisher
//        }
    /// ---<
    
    private func updateProfileDetails(profile: Profile) {
        // change profile text
        personNameLabel.text = profile.name
        personHashTagLabel.text = profile.loginName
        personInfoTextLabel.text = profile.bio
        
        // change profile image
        //self.personImageView.image = profile.avatarImage
        personImageView.layer.masksToBounds = true
        personImageView.layer.cornerRadius = 32
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
        oAuth2TokenStorage.nilTokenInUserDefaults()
        switchToSplashViewController()
    }
    
    
    
}
