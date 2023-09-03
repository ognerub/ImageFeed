//
//  ProfileBody.swift
//  ImageFeed
//
//  Created by Admin on 18.08.2023.
//

import UIKit

/// струетура, которая будет использоваться для парсинга (decode JSON)
struct ProfileResult: Codable {
    let username: String // логин пользователя
    let firstName: String // имя
    let lastName: String? // фамилия
    let bio: String? // краткая информация
}

/// структура к кторой будем приводить распарсенные данные из JSON
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

/// cтруктуры для картинки профиля
struct ImageSizes: Codable {
    var medium: String?
}
struct UserResult: Codable {
    let profileImage: ImageSizes
}
