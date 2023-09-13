//
//  Constants.swift
//  ImageFeed
//
//  Created by Admin on 30.07.2023.
//

import Foundation

let AccessKey = "37Srzq-z50u-dbfAlq6Glut7bUVnbonjepafLeiMQaw"
let SecretKey = "iPrl0R--netyhxGACrrs6EyTLgAZRlovWLWsgG0x6-M"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURLString = "https://api.unsplash.com"
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURLString: String,
        authURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
    }
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 defaultBaseURLString: DefaultBaseURLString,
                                 authURLString: UnsplashAuthorizeURLString)
    }
    
}

