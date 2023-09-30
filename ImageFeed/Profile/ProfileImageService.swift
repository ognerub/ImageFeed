//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Admin on 18.08.2023.
//

import UIKit

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var currentTask: URLSessionTask?
    private (set) var avatarURL: URL?
    private let urlSession: URLSession
    private let builder: URLRequestBuilder
    private let storage: OAuth2TokenStorage
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared,
        storage: OAuth2TokenStorage = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
        self.storage = storage
    }
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void) {
            assert(Thread.isMainThread)
            currentTask?.cancel()
            guard let request = urlRequestWithBearerToken(username: username) else {
                return
            }
            currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult,Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.currentTask = nil
                    switch result {
                    case .success(let body):
                        guard let profileImageURL = body.profileImage.medium else {return}
                        self.avatarURL = URL(string: profileImageURL)
                        self.storage.avatarURL = profileImageURL
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
            }
            currentTask?.resume()
        }
}

private extension ProfileImageService {
    func urlRequestWithBearerToken(username: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/users/\(username)",
            httpMethod: "GET",
            baseURLString: AuthConfiguration.standart.defaultBaseURLString)
    }
}
