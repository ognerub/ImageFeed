//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Admin on 05.08.2023.
//

import Foundation
import UIKit

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage.shared
    private let builder = URLRequestBuilder.shared
    
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
    var errorVar: Error?
    
    var isAuthenticated: Bool {
        oAuth2TokenStorage.token != nil
    }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        taskProtect?.cancel()
        lastCode = code
        guard let request = authTokenRequest(code: code) else {
            assertionFailure("Invalid request while fetchOAuthToken")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self?.taskProtect = nil
                    let authToken = body.accessToken
                    self?.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    self?.lastCode = nil
                    completion(.failure(error))
                
            }
        }
        self.taskProtect = task
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
    }
}
