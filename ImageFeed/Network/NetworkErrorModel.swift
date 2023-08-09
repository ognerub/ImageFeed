//
//  NetworkErrorModel.swift
//  ImageFeed
//
//  Created by Admin on 09.08.2023.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}
