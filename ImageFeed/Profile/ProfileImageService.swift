//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Admin on 18.08.2023.
//

import UIKit

final class ProfileImageService {
    
    struct ImageSizes: Decodable {
        var medium: String?
    }
    struct UserResult: Decodable {
        let profileImage: ImageSizes
    }
    
    // добвили второй синглтон
    static let shared = ProfileImageService()
    
    // добавляем новое имя нотификации
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private (set) var avatarURL: URL?
    
    //private (set) var avatarImage: UIImage = UIImage(systemName: "person.crop.circle.fill")!
    
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage.shared
    private let builder = URLRequestBuilder.shared
    
    private var currentTask: URLSessionTask?
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void) {
            currentTask?.cancel()
            guard let request = urlRequestWithBearerToken(username: username) else {
                print("Nil request in fetchProfileImageURL")
                return
            }
            currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult,Error>) in
                guard let self = self else { return }
                self.currentTask = nil
                switch result {
                case .success(let body):
                    guard let profileImageURL = body.profileImage.medium else {return}
                    self.avatarURL = URL(string: profileImageURL)
                    completion(.success(profileImageURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL]
                    )
                case .failure(let error):
                    completion(.failure(error))
                }
                
            }
            currentTask?.resume()
        }
}

private extension ProfileImageService {
    func urlRequestWithBearerToken(username: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/users/\(username)",
            httpMethod: "GET",
            baseURLString: Constants.defaultAPIURLString)
    }
}
