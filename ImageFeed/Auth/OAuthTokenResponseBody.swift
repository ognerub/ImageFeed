//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Admin on 05.08.2023.
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
