//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Admin on 05.08.2023.
//

import Foundation


final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread) // проверяем что код выполняется из главного потока
        print("The task is \(String(describing: task)) and lastCode is \(String(describing: lastCode)). Check if the task is not nil")
        if lastCode == code {
            print("Check for lastCode == code")
            return // должны выполнить новый запрос
        }
        task?.cancel() // старый запрос при этом нужно отменить, но если task == nil но ничеко не произойдет
        lastCode = code // запоминаем code, использованный в запросе
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            print("Switch to main.async")
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    print("Success block, do task = nil")
                    self.task = nil
                    print("Success block. Task now is \(String(describing: self.task))")
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    print("Error block, do lastCode = nil")
                    self.lastCode = nil
                    print("lastCode now is \(String(describing: self.lastCode))")
                    completion(.failure(error))
                }
            }
        }
        print("Do task = task")
        self.task = task
        print("Task now is \(task)")
        task.resume()
    }
}

private extension OAuth2Service {
    func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
    
    /// метод для запроса токена
    func authTokenRequest(code: String) -> URLRequest {
        let path: String = Constants.unsplashOauthTokenPath
        + "?client_id=\(Constants.accessKey)"
        + "&&client_secret=\(Constants.secretKey)"
        + "&&redirect_uri=\(Constants.redirectURI)"
        + "&&code=\(code)"
        + "&&grant_type=authorization_code"
        guard let url = URL(string: path) else {
            fatalError("Failed to create path URL at authTokenRequest!")
        }
        print("The authTokenRequest URL is: \(url)")
        return URLRequest.makeHTTPRequest(
            path: path,
            httpMethod: "POST",
            baseURL: Constants.defaultBaseURL
        )
    }
}
