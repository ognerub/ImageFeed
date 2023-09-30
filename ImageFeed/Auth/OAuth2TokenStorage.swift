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
        get { keychainWrapper.string(forKey: AuthConfiguration.standart.bearerTokenString) }
        set { guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: AuthConfiguration.standart.bearerTokenString) }
    }
    
    var loginName: String? {
        get { keychainWrapper.string(forKey: "loginNameFromProfile") }
        set { guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: "loginNameFromProfile") }
    }
    
    var hashTag: String? {
        get { keychainWrapper.string(forKey: "hashTagFromProfile") }
        set { guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: "hashTagFromProfile") }
    }
    
    var infoText: String? {
        get { keychainWrapper.string(forKey: "infoTextFromProfile") }
        set { guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: "infoTextFromProfile") }
    }
    
    var avatarURL: String? {
        get { keychainWrapper.string(forKey: "avatarURLFromProfile") }
        set { guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: "avatarURLFromProfile") }
    }
    
    func nilTokenInUserDefaults() {
        token = nil
        keychainWrapper.removeObject(forKey: AuthConfiguration.standart.bearerTokenString)
        clearProfileData()
    }
    
    private func clearProfileData() {
        loginName = nil
        keychainWrapper.removeObject(forKey: "loginNameFromProfile")
        hashTag = nil
        keychainWrapper.removeObject(forKey: "hashTagFromProfile")
        infoText = nil
        keychainWrapper.removeObject(forKey: "infoTextFromProfile")
        avatarURL = nil
        keychainWrapper.removeObject(forKey: "avatarURLFromProfile")
    }
}
