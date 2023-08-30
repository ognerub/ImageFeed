//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Admin on 29.08.2023.
//

import Foundation

final class ImagesListService {
    
    struct PhotoResult: Decodable {
        let id: String
        let createdAt: Date?
        let width: CGFloat
        let height: CGFloat
        let likedByUser: Bool
        let description: String?
        let urls: UrlsResult
    }
    
    struct UrlsResult: Decodable {
        let thumb: String?
        let full: String?
    }
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
    }
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceProviderDidChange")
    
    static let shared = ImagesListService()
    
    private let urlSession: URLSession
    private let builder: URLRequestBuilder
    
    private var currentTask: URLSessionTask?
    private var lastLoadedPage: Int?
    private (set) var photos: [Photo] = []
    private (set) var photo: Photo?
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }
    
    
    func fetchPhotosNextPage(completion: @escaping (Result<Photo, Error>) -> Void) {
        currentTask?.cancel()
        guard let request = urlRequestWithBearerToken() else {
            assertionFailure("Invalide request in fetchProfile")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let nextPage = lastLoadedPage == nil ? 1 : (lastLoadedPage ?? 0) + 1
        
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResult,Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentTask = nil
                switch result {
                case .success(let body):
                    let id = body.id
                    let createdAt = body.createdAt
                    let size = CGSize(width: body.width, height: body.height)
                    let isLiked = body.likedByUser
                    let welcomeDescription = body.description
                    let thumbImageURL = body.urls.thumb ?? "PASTE THUMB"
                    let largeImageURL = body.urls.full ?? "PASTE LARGE IMG"
                    let photo = Photo(
                        id: id,
                        size: size,
                        createdAt: createdAt,
                        welcomeDescription: welcomeDescription,
                        thumbImageURL: thumbImageURL,
                        largeImageURL: largeImageURL,
                        isLiked: isLiked)
                    self.photo = photo
                    completion(.success(photo))
                    NotificationCenter.default.post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": photo]
                    )
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
    func urlRequestWithBearerToken() -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/photos",
            httpMethod: "GET",
            baseURLString: Constants.defaultAPIURLString)
    }
}
