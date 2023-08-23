//
//  URLSession.swift
//  ImageFeed
//
//  Created by Admin on 09.08.2023.
//

import Foundation

extension URLSession {
    
    /// Сетевой запрос на дженериках (сессия с декодированием)
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try decoder.decode(T.self, from: data)
                        fulfillCompletionOnMainThread(.success(result))
                    } catch {
                        fulfillCompletionOnMainThread(.failure(error))
                    }
                } else {
                    print("Error encoding \(String(data: data, encoding: .utf8) ?? "Error data encoding while getting statusCode")")
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
//    /// Стандартный сетевой запрос
//    func data(
//        for request: URLRequest,
//        completion: @escaping (Result<Data, Error>) -> Void
//    ) -> URLSessionTask {
//        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async {
//                completion(result)
//            }
//        }
//        let task = dataTask(with: request, completionHandler: { data, response, error in
//            if let data = data,
//               let response = response,
//               let statusCode = (response as? HTTPURLResponse)?.statusCode
//            {
//                if 200 ..< 300 ~= statusCode {
//                    fulfillCompletion(.success(data))
//                } else {
//                    print("Error encoding \(String(data: data, encoding: .utf8) ?? "Error data encoding while getting statusCode")")
//                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
//                }
//            } else if let error = error {
//                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
//            } else {
//                fulfillCompletion(.failure(NetworkError.urlSessionError))
//            }
//        })
//        task.resume()
//        return task
//    }
}
