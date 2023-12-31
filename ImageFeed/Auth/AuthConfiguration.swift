//
//  Constants.swift
//  ImageFeed
//
//  Created by Admin on 30.07.2023.
//

import Foundation

let access = "37Srzq-z50u-dbfAlq6Glut7bUVnbonjepafLeiMQaw"
let secret = "iPrl0R--netyhxGACrrs6EyTLgAZRlovWLWsgG0x6-M"
let redirect = "urn:ietf:wg:oauth:2.0:oob"
let scope = "public+read_user+write_likes"
let base = "https://api.unsplash.com"
let auth = "https://unsplash.com/oauth/authorize"
let bearer = "Bearer Token"
let scaled = 700.0 /// this is scaled width of image to export (share with telegram or whats app)

struct AuthConfiguration {
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String
    let bearerTokenString: String
    let scaledWidth: Double

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURLString: String,
        authURLString: String,
        bearerTokenString: String,
        scaledWidth: Double
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
        self.bearerTokenString = bearerTokenString
        self.scaledWidth = scaledWidth
    }
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(accessKey: access,
                                 secretKey: secret,
                                 redirectURI: redirect,
                                 accessScope: scope,
                                 defaultBaseURLString: base,
                                 authURLString: auth,
                                 bearerTokenString: bearer,
                                 scaledWidth: scaled)
    }
    
}

