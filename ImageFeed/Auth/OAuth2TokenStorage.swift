//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Admin on 05.08.2023.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let userDefaults: UserDefaults
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    enum Keys: String {
        case userToken
    }
    
    var token: String? {
        get {
            userDefaults.string(forKey: Keys.userToken.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.userToken.rawValue)
        }
    }
}
