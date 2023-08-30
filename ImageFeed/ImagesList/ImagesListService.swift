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
        let createdAt: String
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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    } ()
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }
    
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        currentTask?.cancel()
        guard let request = urlRequestWithBearerToken() else {
            assertionFailure("Invalide request in fetchProfile")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let nextPage = lastLoadedPage == nil ? 1 : (lastLoadedPage ?? 0) + 1
        
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
                            createdAt: self.dateFormatter.date(from: item.createdAt),
                            welcomeDescription: item.description,
                            thumbImageURL: item.urls.thumb ?? "NO THUMB",
                            largeImageURL: item.urls.full ?? "NO FULL IMG",
                            isLiked: item.likedByUser)
                        photos.append(photo)
                    }
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage? += 1
                    completion(.success(photos))
                    NotificationCenter.default.post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["PHOTOS": self.photos]
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
            path: "/photos/",
            httpMethod: "GET",
            baseURLString: Constants.defaultAPIURLString)
    }
}