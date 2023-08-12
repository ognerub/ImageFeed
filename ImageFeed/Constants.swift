//
//  Constants.swift
//  ImageFeed
//
//  Created by Admin on 30.07.2023.
//

import Foundation

struct Constants {
    static let accessKey = "37Srzq-z50u-dbfAlq6Glut7bUVnbonjepafLeiMQaw"
    static let secretKey = "iPrl0R--netyhxGACrrs6EyTLgAZRlovWLWsgG0x6-M"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "http://unsplash.com")!
    static let code = "code"
    static let unsplashAuthorizeURLString: String = "https://unsplash.com/oauth/authorize"
    static let unsplashOauthTokenPath = "/oauth/token/"
}

