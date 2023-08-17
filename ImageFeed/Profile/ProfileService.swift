//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Admin on 17.08.2023.
//

import Foundation

final class ProfileService {
    
    struct ProfileResult: Decodable {
        let username: String // логин пользователя
        let firstName: String // имя
        let lastName: String? // фамилия
        let bio: String? // краткая информация
        //let profileImage: String // картинка профиля
        //
        //        enum CodingKeys: String, CodingKey {
        //            case id = "id"
        //        }
    }
    
    struct Profile {
        let username: String // логин пользователя в том же виде, каком получаем его
        let name: String // конкатенация имени и фамилии (firstName + lastName)
        let loginName: String // логин пользователя со знаком @ перед первым символом
        let bio: String // совпадает с ProfileResult.bio
    }
    
    private let urlSession = URLSession.shared
    let authToken: String? = OAuth2TokenStorage().token
    var profile: Profile = Profile(username: "Noname", name: "Has Noname", loginName: "@Noname", bio: "Bio should be here")
    
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void) {
            guard let token = authToken else {
                print("Token is empty!")
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
                        let profile = Profile(username: username, name: "\(firstName) \(lastName)", loginName: "@\(username)", bio: bio ?? "")
                        self.profile = profile
                        completion(.success(profile))
                    case .failure(let error):
                        print("Error result is \(result)")
                        completion(.failure(error))
                    }
                }
                
            }
            task.resume()
        }
    
    func urlRequestWithBearerToken(token: String) -> URLRequest {
        let url: URL = URL(string: "\(Constants.defaultAPIURL)/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
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
                    print("All ok, the object is \(object)")
                    completion(.success(object))
                } catch {
                    print("First error \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Second error \(error)")
                completion(.failure(error))
            }
        }
    }
}


