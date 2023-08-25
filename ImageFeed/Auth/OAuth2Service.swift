//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Admin on 05.08.2023.
//

import Foundation


final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession: URLSession
    private let storage: OAuth2TokenStorage
    private let builder: URLRequestBuilder
    
    private (set) var authToken: String? {
        get {
            return storage.token
        }
        set {
            storage.token = newValue
        }
    }
    
    private var taskProtect: URLSessionTask?
    private var lastCode: String?
    
    init (
        urlSession: URLSession = .shared,
        storage: OAuth2TokenStorage = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.storage = storage
        self.builder = builder
    }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread) // проверяем что код выполняется из главного потока
        print("The task is \(String(describing: taskProtect)) and lastCode is \(String(describing: lastCode)). Check if the task is not nil")
        if lastCode == code {
            print("Check for lastCode == code")
            return // должны выполнить новый запрос
        }
        taskProtect?.cancel() // старый запрос при этом нужно отменить, но если task == nil но ничеко не произойдет
        lastCode = code // запоминаем code, использованный в запросе
        guard let request = authTokenRequest(code: code) else {
            print("Nil request in fetchOAuthToken")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody,Error>) in
            print("Switch to main.async")
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    print("Success block, do task = nil")
                    self?.taskProtect = nil
                    print("Success block. Task now is \(String(describing: self?.taskProtect))")
                    let authToken = body.accessToken
                    self?.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    print("Error block, do lastCode = nil")
                    self?.lastCode = nil
                    print("lastCode now is \(String(describing: self?.lastCode))")
                    completion(.failure(error))
                }
            }
        }
        print("Do task = task")
        self.taskProtect = task
        print("Task now is \(task)")
        task.resume()
    }
}

private extension OAuth2Service {
    /// метод для запроса токена
    func authTokenRequest(code: String) -> URLRequest? {
//        var urlComponents = URLComponents(string: Constants.unsplashOauthTokenPath)
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "client_id", value: Constants.accessKey),
//            URLQueryItem(name: "client_secret", value: Constants.secretKey),
//            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
//            URLQueryItem(name: "code", value: code),
//            URLQueryItem(name: "grant_type", value: "authorization_code")
//        ]
        let path: String = Constants.unsplashOauthTokenPath
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code"
                guard let url = URL(string: path) else {
                    fatalError("Failed to create path URL at authTokenRequest! Path is \(path)")
                }
        return builder.makeHTTPRequest(
            path: path,
            httpMethod: "POST",
            baseURLString: Constants.defaultBaseURLString)
        
//
//        print("The authTokenRequest URL is: \(url)")
//        return URLRequest.makeHTTPRequest(
//            path: path,
//            httpMethod: "POST",
//            baseURL: Constants.defaultBaseURL
//        )
    }
}
