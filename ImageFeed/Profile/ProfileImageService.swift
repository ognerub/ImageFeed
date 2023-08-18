//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Admin on 18.08.2023.
//

import Foundation

final class ProfileImageService {
    struct UserResult: Decodable {
        
        let profileImage: ImageSizes
        
        struct ImageSizes: Codable {
            let small: String
            let medium: String
            let large: String
        }
    }
    
    private let urlSession = URLSession.shared
    
    private let authToken: String? = OAuth2TokenStorage().token
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<UserResult, Error>) -> Void) {
            guard let token = authToken else {
                //print("Token is empty while fetchPtofile in ProfileService")
                return
            }
            let request = urlRequestWithBearerToken(token: token, username: username)
            let task = object(for: request) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let body):
                        print("We`ve got: \(body)")
                        //guard let url: String? = first else { return }
                        completion(.success(body))
                    case .failure(let error):
                        //print("Error while fetchProfile in ProfileService. Result is \(result) ")
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
}

private extension ProfileImageService {
    
    /// создаем GET запрос с использованием Bearer токена, планурием получить в ответе JSON
    func urlRequestWithBearerToken(token: String, username: String) -> URLRequest {
        let url: URL = URL(string: "\(Constants.defaultAPIURL)/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    /// пытаемся распрарсить (decode JSON) в соответсвии с заданной структурой
    func object(
        for request: URLRequest,
        completion: @escaping (Result<UserResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
//                    if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) {
//                        do {
//                            let userResult = try JSONDecoder().decode(UserResult.self, from: jsonData)
//                            print("JSON now is \(userResult)")
//                        } catch { print ("error") }
//                    }
                    
                    
                    let object = try decoder.decode(
                        UserResult.self,
                        from: data)
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
