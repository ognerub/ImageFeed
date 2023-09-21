//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Admin on 05.08.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: "Bearer Token")
        }
        set {
            guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: "Bearer Token")
        }
    }
    
    func nilTokenInUserDefaults() {
        token = nil
        keychainWrapper.removeObject(forKey: "Bearer Token")
    }
}
