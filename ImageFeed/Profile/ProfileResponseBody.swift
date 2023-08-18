//
//  ProfileBody.swift
//  ImageFeed
//
//  Created by Admin on 18.08.2023.
//

import Foundation

/// струетура, которая будет использоваться для парсинга (decode JSON)
struct ProfileResult: Codable {
    let username: String // логин пользователя
    let firstName: String // имя
    let lastName: String // фамилия
    let bio: String // краткая информация
}

/// структура к кторой будем приводить распарсенные данные из JSON
struct Profile {
    let username: String // логин пользователя в том же виде, каком получаем его
    let name: String // конкатенация имени и фамилии (firstName + lastName)
    let loginName: String // логин пользователя со знаком @ перед первым символом
    let bio: String // совпадает с ProfileResult.bio
}
