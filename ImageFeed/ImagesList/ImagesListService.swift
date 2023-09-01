//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Admin on 29.08.2023.
//

import Foundation

final class ImagesListService {
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceProviderDidChange")
    
    static let shared = ImagesListService()
    
    private let urlSession: URLSession
    private let builder: URLRequestBuilder
    
    private var currentTask: URLSessionTask?
    private var lastLoadedPage: Int = 0
    private (set) var photos: [Photo] = []
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }
    
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        if currentTask != nil {
            print("TaskInProgress guard return from func")
            return
        } else {
            print("No task make progress true")
            currentTask?.cancel()
        }
        let nextPage = lastLoadedPage + 1
        guard let request = urlRequestWithBearerToken(page: nextPage) else {
            assertionFailure("Invalide request in fetchProfile")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult],Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentTask = nil
                switch result {
                case .success(let result):
                    var photos: [Photo] = []
                    for item in result {
                        let photo = Photo(
                            id: item.id,
                            size: CGSize(width: item.width, height: item.height),
                            createdAt: item.createdAt,
                            welcomeDescription: item.description,
                            thumbImageURL: item.urls.thumb ?? "NO THUMB",
                            largeImageURL: item.urls.full ?? "NO FULL IMG",
                            isLiked: item.likedByUser)
                        photos.append(photo)
                    }
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage = self.lastLoadedPage + 1
                    NotificationCenter.default.post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["Photos": photos]
                    )
                    completion(.success(photos))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        currentTask?.resume()
    }
}

private extension ImagesListService {
    
    /// создаем GET запрос с использованием Bearer токена, планурием получить в ответе JSON
    func urlRequestWithBearerToken(page: Int) -> URLRequest? {
        let path: String = "/photos?"
        + "page=\(page)"
        + "&&per_page=10"
        return builder.makeHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: Constants.defaultAPIURLString)
    }
}
