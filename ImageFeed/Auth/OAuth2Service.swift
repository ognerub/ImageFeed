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
        assert(Thread.isMainThread)
        guard lastCode != code else { return }
        taskProtect?.cancel()
        lastCode = code
        guard let request = authTokenRequest(code: code) else {
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self?.taskProtect = nil
                    let authToken = body.accessToken
                    self?.storage.token = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    self?.lastCode = nil
                    completion(.failure(error))
                }
            }
        }
        self.taskProtect = task
        task.resume()
    }
}

private extension OAuth2Service {
    /// метод для запроса токена
    func authTokenRequest(code: String) -> URLRequest? {
        let path: String = Constants.unsplashOauthTokenPath
        + "?client_id=\(Constants.accessKey)"
        + "&&client_secret=\(Constants.secretKey)"
        + "&&redirect_uri=\(Constants.redirectURI)"
        + "&&code=\(code)"
        + "&&grant_type=authorization_code"
        return builder.makeHTTPRequest(
            path: path,
            httpMethod: "POST",
            baseURLString: Constants.defaultBaseURLString)
    }
}
