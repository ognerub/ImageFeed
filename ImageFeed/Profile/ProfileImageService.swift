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
    private let storage: OAuth2TokenStorage
    private let builder: URLRequestBuilder
    
    init (
        urlSession: URLSession = .shared,
        storage: OAuth2TokenStorage = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.storage = storage
        self.builder = builder
    }
    
    
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void) {
            assert(Thread.isMainThread)
            currentTask?.cancel()
            guard let request = urlRequestWithBearerToken(username: username) else {
                print("Nil request in fetchProfileImageURL")
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
            baseURLString: Constants.defaultAPIURLString)
    }
}
