//
//  URLRequest.swift
//  ImageFeed
//
//  Created by Admin on 09.08.2023.
//

import Foundation

final class URLRequestBuilder {
    static let shared = URLRequestBuilder()
    
    private let storage: OAuth2TokenStorage
    
    init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }
    
    func makeHTTPRequest (
        path: String,
        httpMethod: String,
        baseURLString: String) -> URLRequest? {
            guard
                baseURLString.isValidURL,
                let url = URL(string: baseURLString),
                let baseURL = URL(string: path, relativeTo: url)
            else { return nil }
            
            var request = URLRequest(url: baseURL)
            request.httpMethod = httpMethod
            request.timeoutInterval = 15
            if let token = storage.token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return request
        }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
