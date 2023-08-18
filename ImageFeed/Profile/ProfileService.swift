//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Admin on 17.08.2023.
//

import Foundation

final class ProfileService {
    
    // создаем наш первый и самый простой синглтон
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    
    let authToken: String? = OAuth2TokenStorage().token
    
    private (set) var profile: Profile?
    
    /// получаем информаю профиля в соответсвии с заданной структурой
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void) {
            guard let token = authToken else {
                //print("Token is empty while fetchPtofile in ProfileService")
                return
            }
            let request = urlRequestWithBearerToken(token: token)
            let task = object(for: request) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let body):
                        let username = body.username
                        let firstName = body.firstName
                        let lastName = body.lastName
                        let bio = body.bio
                        let profile = Profile(username: username, name: "\(firstName) \(lastName)", loginName: "@\(username)", bio: bio)
                        self.profile = profile
                        completion(.success(profile))
                    case .failure(let error):
                        //print("Error while fetchProfile in ProfileService. Result is \(result) ")
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
}

extension ProfileService {
    
    /// создаем GET запрос с использованием Bearer токена, планурием получить в ответе JSON
    func urlRequestWithBearerToken(token: String) -> URLRequest {
        let url: URL = URL(string: "\(Constants.defaultAPIURL)/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    /// пытаемся распрарсить (decode JSON) в соответсвии с заданной структурой
    func object(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(
                        ProfileResult.self,
                        from: data
                    )
                    //print("All ok, the object is \(object)")
                    completion(.success(object))
                } catch {
                    //print("First error \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                //print("Second error \(error)")
                completion(.failure(error))
            }
        }
    }
}


