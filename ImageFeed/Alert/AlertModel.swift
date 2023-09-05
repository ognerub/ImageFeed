//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Admin on 21.08.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}

struct AlertModel2 {
    let title: String
    let message: String
    let buttonText1: String
    let buttonText2: String
    let completion1: () -> Void
    let completion2: () -> Void
}
