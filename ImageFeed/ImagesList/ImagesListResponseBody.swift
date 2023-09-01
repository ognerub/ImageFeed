//
//  ImagesListResponseBody.swift
//  ImageFeed
//
//  Created by Admin on 01.09.2023.
//

import Foundation

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
