//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Admin on 21.08.2023.
//

import Foundation

struct AlertModel {
    var title: String
    let message: String
    let firstButton: String
    let secondButton: String?
    let firstCompletion: () -> Void
    let secondCompletion: () -> Void?
}
