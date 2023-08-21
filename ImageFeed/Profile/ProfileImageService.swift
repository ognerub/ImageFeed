//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Admin on 18.08.2023.
//

import UIKit

final class ProfileImageService {
    
    struct ImageSizes: Decodable {
        var small: String
    }
    struct UserResult: Decodable {
        let profileImage: ImageSizes
    }
    
    private let urlSession = URLSession.shared
    private let authToken: String? = OAuth2TokenStorage().token
    
    // добвили второй синглтон
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    
    // добавляем новое имя нотификации
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void) {
            guard let token = authToken else {
                return
            }
            let request = urlRequestWithBearerToken(token: token, username: username)
            /// также удаляем старый task и прописываем новый
            //let task = object(for: request) { [weak self] result in
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult,Error>) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let body):
                        let profileImageURL = body.profileImage.small
                        self.avatarURL = profileImageURL
                        
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.DidChangeNotification,
                                object: self,
                                userInfo: ["URL": profileImageURL])

                        completion(.success(profileImageURL))
                        
                    case .failure(let error):
                        //print("Error while fetchImageProfile in ProfileImageService. Result is \(result) ")
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
    
//    /// пытаемся распрарсить (decode JSON) в соответсвии с заданной структурой
//    func object(
//        for request: URLRequest,
//        completion: @escaping (Result<UserResult, Error>) -> Void
//    ) -> URLSessionTask {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return urlSession.data(for: request) { (result: Result<Data, Error>) in
//            switch result {
//            case .success(let data):
//                do {
//                    let object = try decoder.decode(
//                        UserResult.self,
//                        from: data)
//                    let urlString = object.profileImage.small
//                    print("All ok, the object is \(urlString)")
//                    completion(.success(object))
//                } catch {
//                    print("First error \(error)")
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                print("Second error \(error)")
//                completion(.failure(error))
//            }
//        }
//    }
}
