//
//  URLRequest.swift
//  ImageFeed
//
//  Created by Admin on 09.08.2023.
//

import Foundation

extension URLRequest {
    /// функция для создания HTTP запроса
    static func makeHTTPRequest (
        path: String,
        httpMethod: String,
        baseURL: URL = Constants.defaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}
