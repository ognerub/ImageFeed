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
    
    var lastLoadedPage: Int?
    
    private let urlSession: URLSession
    private let builder: URLRequestBuilder
    
    private var currentTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    private (set) var photos: [Photo] = []
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }
    
    func getNextPage() -> Int {
        guard let lastLoadedPage = lastLoadedPage else { return 1 }
        let currentPage = lastLoadedPage
        let nextPage = currentPage + 1
        return nextPage
    }
    
    func nillLasLoadedPage() {
        lastLoadedPage = nil
    }
    
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        if currentTask != nil { return } else { currentTask?.cancel() }
        let nextPage = getNextPage()
        guard let request = urlRequestWithBearerToken(page: nextPage) else {
            print("Invalide request in fetchPhotosNextPage")
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
                            createdAt: item.createdAt?.formatISODateString(dateFormat: item.createdAt),
                            welcomeDescription: item.description,
                            thumbImageURL: item.urls.thumb ?? "NO THUMB",
                            largeImageURL: item.urls.full ?? "NO FULL IMG",
                            isLiked: item.likedByUser)
                        photos.append(photo)
                    }
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage = nextPage
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
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        if likeTask != nil { return } else { likeTask?.cancel() }
        guard let request = urlRequestForChangeLike(photoId: photoId, isLike: isLike) else {
            print("Invalide request in changeLike")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        likeTask = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResponse,Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.likeTask = nil
                switch result {
                case .success(_):
                    // поиск индекса элемента
                    if let index = self.photos.firstIndex(where: {$0.id == photoId}) {
                        // текуший элемент
                        let photo = self.photos[index]
                        // копия элемента с инвертированным значением isLiked
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        // замена элемента в массиве
                        self.photos[index] = newPhoto
                        completion(.success(()))
                    }
                case.failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.likeTask?.resume()
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
            baseURLString: AuthConfiguration.standart.defaultBaseURLString)
    }
    /// создаем  запросы для  лайков
    func urlRequestForChangeLike(photoId: String, isLike: Bool) -> URLRequest? {
        let path: String = "/photos/\(photoId)/like"
        let httpMethod = isLike ? "POST" : "DELETE"
        return builder.makeHTTPRequest(
            path: path,
            httpMethod: httpMethod,
            baseURLString: AuthConfiguration.standart.defaultBaseURLString)
    }
    
}
