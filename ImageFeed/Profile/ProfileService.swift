//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Admin on 17.08.2023.
//

import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private let builder: URLRequestBuilder
    private let urlSession: URLSession
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    
    init(
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }
    
    /// получаем информаю профиля в соответсвии с заданной структурой
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        guard let request = urlRequestWithBearerToken() else {
            assertionFailure("Invalide request in fetchProfile")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult,Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentTask = nil
                switch result {
                case .success(let body):
                    let username = body.username
                    let firstName = body.firstName
                    let lastName = body.lastName
                    let bio = body.bio
                    let profile = Profile(username: username, name: "\(firstName) \(lastName ?? "")", loginName: "@\(username)", bio: bio ?? "")
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        currentTask?.resume()
    }
}

private extension ProfileService {
    
    /// создаем GET запрос с использованием Bearer токена, планурием получить в ответе JSON
    func urlRequestWithBearerToken() -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURLString: AuthConfiguration.standart.defaultBaseURLString)
    }
}


